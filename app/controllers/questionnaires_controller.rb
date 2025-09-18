class QuestionnairesController < ApplicationController
  def index
    @questionnaires = Questionnaire.active.order(:position)
  end

  def show
    @questionnaire = Questionnaire.friendly.find(params[:id])
  end

  def start
    @questionnaire = Questionnaire.friendly.find(params[:id])

    # Créer nouvelle session
    @session = @questionnaire.questionnaire_sessions.build(
      started_at: Time.current,
      ip_address: request.remote_ip.present? ? request.remote_ip : '127.0.0.1',
      user_agent: request.user_agent.present? ? request.user_agent : 'Unknown',
      current_question: @questionnaire.first_question
    )

    # Force generation of session token if not present
    @session.send(:generate_session_token) if @session.session_token.blank?

    @session.save!

    session[:questionnaire_session_token] = @session.session_token

    redirect_to question_path(@session.current_question.id)
  end
end
