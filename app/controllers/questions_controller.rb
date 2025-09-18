class QuestionsController < ApplicationController
  before_action :require_session!, except: :show
  before_action :set_question

  def show
    if @current_session && !@question.visible_for?(@current_session)
      # Trouve la prochaine question visible
      next_q = find_next_visible_question
      if next_q
        redirect_to question_path(next_q.id)
      else
        redirect_to results_path
      end
      return
    end

    @answer = @current_session&.answer_for(@question)
    @progress = @current_session&.progress_percentage || 0
    @previous_question = @current_session ? find_previous_answered_question : nil
  end

  def answer
    # Sauvegarder la réponse
    @response = @current_session.user_responses.find_or_initialize_by(
      question: @question
    )

    # Gérer les différents types de questions
    if params[:answer_codes].present?
      # Choix multiples (plâtrerie)
      selected_labels = []
      params[:answer_codes].each do |code|
        option = @question.answer_options.find_by(code: code)
        selected_labels << option.label if option
      end

      @response.update!(
        answer: selected_labels.join(', '),
        answer_code: JSON.generate(params[:answer_codes]),
        answered_at: Time.current
      )
    elsif @question.question_type == 'number_input'
      # Input numérique - utiliser answer_code comme answer
      @response.update!(
        answer: params[:answer_code],
        answer_code: params[:answer_code],
        answered_at: Time.current
      )
    elsif @question.metadata&.dig('requires_quantity') && params[:quantities].present?
      # Quantités multiples (passages mur)
      quantities = params.require(:quantities).permit!.to_h.transform_values(&:to_i).select { |code, qty| qty > 0 }

      # Calculer le total des points
      total_points = 0
      details = []
      quantities.each do |code, qty|
        option = @question.answer_options.find_by(code: code)
        if option&.metadata&.dig('points')
          points = option.metadata['points'].to_f * qty
          total_points += points
          details << "#{option.label}: #{qty} × #{option.metadata['points']} = #{points}"
        end
      end

      # Stocker les données dans answer_code en JSON
      answer_data = {
        type: 'multiple_quantities',
        quantities: quantities,
        total_points: total_points,
        details: details
      }

      @response.update!(
        answer: "Total passages mur: #{total_points} points",
        answer_code: answer_data.to_json,
        answered_at: Time.current
      )
    else
      # Choix unique standard
      @response.update!(
        answer: params[:answer],
        answer_code: params[:answer_code],
        answered_at: Time.current
      )
    end

    # Trouver prochaine question
    next_question = find_next_question

    if next_question
      @current_session.update!(current_question: next_question)
      redirect_to question_path(next_question.id)
    else
      # Calculer le coefficient total pour le questionnaire de pose
      if @current_session.questionnaire.slug == 'coefficient-pose'
        calculate_pose_coefficient
      end

      @current_session.update!(completed_at: Time.current)
      redirect_to results_path
    end
  end

  def previous
    previous_question = find_previous_answered_question

    if previous_question
      @current_session.update!(current_question: previous_question)
      redirect_to question_path(previous_question.id)
    else
      redirect_to questionnaire_path(@current_session.questionnaire)
    end
  end

  private

  def set_question
    @question = Question.find(params[:id])
  end


  def calculate_pose_coefficient
    base_coefficient = @current_session.questionnaire.settings['base_coefficient'] || 4.5
    total_points = base_coefficient

    # Calculer la somme de tous les points
    @current_session.user_responses.includes(question: :answer_options).each do |response|
      # Pour les choix simples avec quantités multiples (passages mur)
      if response.question.question_type == 'single_choice' && response.question.metadata&.dig('requires_quantity')
        begin
          answer_data = JSON.parse(response.answer_code)
          if answer_data['type'] == 'multiple_quantities' && answer_data['total_points']
            # Nouvelle logique avec quantités multiples
            total_points += answer_data['total_points'].to_f
          else
            # Ancienne logique pour compatibilité
            option = response.question.answer_options.find_by(code: response.answer_code)
            if option&.metadata&.dig('points')
              total_points += option.metadata['points'].to_f
            end
          end
        rescue JSON::ParserError
          # Si ce n'est pas du JSON, traiter comme ancienne logique
          option = response.question.answer_options.find_by(code: response.answer_code)
          if option&.metadata&.dig('points')
            total_points += option.metadata['points'].to_f
          end
        end

      # Pour les choix simples standards
      elsif response.question.question_type == 'single_choice'
        option = response.question.answer_options.find_by(code: response.answer_code)
        total_points += option.metadata['points'].to_f if option&.metadata&.dig('points')

      # Pour les choix multiples (plâtrerie)
      elsif response.question.question_type == 'multiple_choice'
        answer_codes = JSON.parse(response.answer_code) rescue []
        answer_codes.each do |code|
          option = response.question.answer_options.find_by(code: code)
          total_points += option.metadata['points'].to_f if option&.metadata&.dig('points')
        end
      end
    end

    # Sauvegarder le résultat
    @current_session.create_result!(
      product_kits: {
        coefficient_total: total_points.round(2),
        base: base_coefficient,
        details: generate_coefficient_details
      },
      generated_at: Time.current
    )
  end

  def generate_coefficient_details
    details = []

    @current_session.user_responses.includes(question: :answer_options).each do |response|
      if response.question.metadata&.dig('points_field')
        # Pour les choix simples avec quantités multiples (passages mur)
        if response.question.question_type == 'single_choice' && response.question.metadata&.dig('requires_quantity')
          begin
            answer_data = JSON.parse(response.answer_code)
            if answer_data['type'] == 'multiple_quantities' && answer_data['details']
              # Nouvelle logique avec quantités multiples
              answer_data['details'].each do |detail|
                details << {
                  question: response.question.title,
                  answer: detail,
                  points: nil # Les points sont inclus dans le détail
                }
              end
              # Ajouter le total
              details << {
                question: response.question.title,
                answer: "Total passages mur",
                points: answer_data['total_points'].to_f
              }
            else
              # Ancienne logique pour compatibilité
              option = response.question.answer_options.find_by(code: response.answer_code)
              if option&.metadata&.dig('points') && option.metadata['points'].to_f > 0
                details << {
                  question: response.question.title,
                  answer: option.label,
                  points: option.metadata['points'].to_f
                }
              end
            end
          rescue JSON::ParserError
            # Si ce n'est pas du JSON, traiter comme ancienne logique
            option = response.question.answer_options.find_by(code: response.answer_code)
            if option&.metadata&.dig('points') && option.metadata['points'].to_f > 0
              details << {
                question: response.question.title,
                answer: option.label,
                points: option.metadata['points'].to_f
              }
            end
          end

        # Pour les choix simples standards
        elsif response.question.question_type == 'single_choice'
          option = response.question.answer_options.find_by(code: response.answer_code)
          if option&.metadata&.dig('points') && option.metadata['points'].to_f > 0
            details << {
              question: response.question.title,
              answer: option.label,
              points: option.metadata['points'].to_f
            }
          end

        # Pour les choix multiples (plâtrerie)
        elsif response.question.question_type == 'multiple_choice'
          answer_codes = JSON.parse(response.answer_code) rescue []
          answer_codes.each do |code|
            option = response.question.answer_options.find_by(code: code)
            if option&.metadata&.dig('points') && option.metadata['points'].to_f > 0
              details << {
                question: response.question.title,
                answer: option.label,
                points: option.metadata['points'].to_f
              }
            end
          end
        end
      end
    end

    details
  end

  def find_next_question
    # Pour le questionnaire de pose, gérer l'ordre avec les questions dynamiques
    if @current_session.questionnaire.slug == 'coefficient-pose'
      all_questions = @current_session.questionnaire.questions
                                      .where('position > ?', @question.position)
                                      .order(:position)

      # Vérifier s'il y a des questions masquées qui nécessitent une réponse automatique
      all_questions.each do |question|
        unless question.visible_for?(@current_session)
          create_automatic_response_if_needed(question)
        end
      end

      all_questions.find { |q| q.visible_for?(@current_session) }
    else
      @question.next_question_for(@current_session)
    end
  end

  def find_next_visible_question
    @current_session.questionnaire.questions
                    .where('position > ?', @question.position)
                    .find { |q| q.visible_for?(@current_session) }
  end

  def find_previous_answered_question
    @current_session.user_responses
                    .joins(:question)
                    .where('questions.position < ?', @question.position)
                    .order('questions.position DESC')
                    .first&.question
  end

  def create_automatic_response_if_needed(question)
    # Vérifier si une réponse existe déjà
    existing_response = @current_session.user_responses.find_by(question: question)
    return if existing_response

    # Logique spécifique pour QP9 (Type de solin)
    if question.code == 'QP9'
      # Trouver l'option "Pas de solin nécessaire" (RP6)
      no_solin_option = question.answer_options.find_by(code: 'RP6')

      if no_solin_option
        @current_session.user_responses.create!(
          question: question,
          answer: no_solin_option.label,
          answer_code: no_solin_option.code,
          answered_at: Time.current
        )
        Rails.logger.info "Réponse automatique créée pour #{question.code}: #{no_solin_option.label}"
      end
    end
  end
end
