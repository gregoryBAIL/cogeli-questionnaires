class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protect_from_forgery with: :exception

  before_action :set_current_session

  private

  def set_current_session
    if session[:questionnaire_session_token].present?
      @current_session = QuestionnaireSession.find_by(
        session_token: session[:questionnaire_session_token]
      )
    end
  end

  def require_session!
    redirect_to root_path unless @current_session
  end
end
