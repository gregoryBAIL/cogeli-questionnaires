class QuestionsController < ApplicationController
  before_action :set_question
  
  def show
    @questionnaire = @question.questionnaire
    @answer_options = @question.answer_options.order(:position)
    
    # Récupérer la réponse précédente si elle existe
    if session[:answers] && session[:answers][@question.id.to_s]
      @selected_answer = session[:answers][@question.id.to_s]
    end
  end
  
  def answer
    # Sauvegarder la réponse en session
    session[:answers] ||= {}
    session[:answers][params[:id]] = params[:answer]
    session[:current_answers] ||= {}
    session[:current_answers][params[:answer_code]] = params[:answer]
    
    # Trouver la prochaine question
    next_question = @question.next_question
    
    if next_question
      redirect_to question_path(next_question)
    else
      redirect_to results_path
    end
  end
  
  private
  
  def set_question
    @question = Question.find(params[:id])
  end
end
