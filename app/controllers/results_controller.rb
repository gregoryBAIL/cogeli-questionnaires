class ResultsController < ApplicationController
  before_action :require_session!
  before_action :require_completed_session!

  def show
    @result = @current_session.result || generate_result

    # Traitement différent selon le type de questionnaire
    if @current_session.questionnaire.slug == 'coefficient-pose'
      # Pour le questionnaire coefficient, pas besoin d'organiser les kits
      # Les données sont déjà dans @result.product_kits
    else
      # Pour le questionnaire fumisterie, organiser les kits par catégorie
      all_kits = @result.product_kits || []

      @grouped_kits = {
        'raccordement' => all_kits.select { |kit| kit['code']&.start_with?('RA') },
        'conduit' => all_kits.select { |kit| kit['code']&.start_with?('CF') },
        'liaison' => all_kits.select { |kit| kit['code']&.start_with?('LI') },
        'finition' => all_kits.select { |kit| kit['code']&.start_with?('FH') },
        'option' => all_kits.select { |kit| kit['code']&.start_with?('DEVRAC', 'FHREH') }
      }
    end
  end

  def download
    @result = @current_session.result

    respond_to do |format|
      format.pdf do
        # PDF generation would be implemented here
        redirect_to results_path, alert: "PDF generation not yet implemented"
      end
    end
  end

  def email
    @result = @current_session.result

    if params[:email].present?
      # Email sending would be implemented here
      @result.update!(sent_by_email: true, email: params[:email])

      flash[:success] = "Configuration envoyée à #{params[:email]}"
    end

    redirect_to results_path
  end

  private

  def require_completed_session!
    unless @current_session&.completed?
      redirect_to root_path, alert: "Questionnaire non complété"
    end
  end

  def generate_result
    if @current_session.questionnaire.slug == 'coefficient-pose'
      # Pour le questionnaire coefficient, le résultat est déjà généré par le contrôleur Questions
      # On retourne un résultat vide si pas encore calculé
      @current_session.create_result!(
        product_kits: {},
        generated_at: Time.current
      )
    else
      # Pour le questionnaire fumisterie, générer les kits
      kits = ProductKit.find_matches_for(@current_session)

      @current_session.create_result!(
        product_kits: kits.map { |k| k.as_json },
        generated_at: Time.current
      )
    end
  end
end
