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

  def find_next_question
    @question.next_question_for(@current_session)
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

end

  private
  
  def save_answer_to_session
    session[:answers] ||= {}
    session[:answers][params[:id]] = params[:answer]
  end

  private
  
  def save_answer_to_session
    session[:answers] ||= {}
    session[:answers][params[:id]] = params[:answer]
  end
