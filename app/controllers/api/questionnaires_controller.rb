# app/controllers/api/questionnaires_controller.rb
class Api::QuestionnairesController < ApplicationController
  skip_before_action :verify_authenticity_token # Si API pure
  # OU garder le CSRF token comme dans le JS

  def save_results
    session = QuestionnaireSession.create!(
      questionnaire_id: 1,
      session_token: SecureRandom.urlsafe_base64(32),
      completed_at: Time.current,
      metadata: {
        answers: params[:answers],
        kits: params[:kits],
        total: params[:total]
      }
    )

    session.create_result!(
      product_kits: params[:kits],
      generated_at: Time.current
    )

    render json: { success: true, session_id: session.id }
  rescue => e
    render json: { success: false, error: e.message }, status: 422
  end

  def generate_pdf
    @kits = params[:kits]
    @total = params[:total]
    @answers = params[:answers]
    @date = Date.current

    # Mapper les réponses aux labels pour le PDF
    @configuration = {
      'Sortie du poêle' => @answers['Q1'] == 'R1' ? 'Arrière' : 'Dessus',
      'Type installation' => @answers['Q2'] == 'R1' ? 'Ventouse' : 'Standard'
    }

    if @answers['Q2'] == 'R2'  # Si pas ventouse
      @configuration['Diamètre raccordement'] = get_diameter_label(@answers['Q3'])
      @configuration['Liaison'] = get_liaison_label(@answers['Q4'])
      @configuration['Type travaux'] = get_work_type_label(@answers['Q5'])
      @configuration['Hauteur conduit'] = "#{@answers['Q6']} mètres"
      @configuration['Diamètre conduit'] = get_diameter_label(@answers['Q7'])
      @configuration['Type toiture'] = get_roof_label(@answers['Q8'])
    end

    pdf = render_to_string(
      pdf: 'configuration_cogeli',
      template: 'api/questionnaires/pdf',
      layout: 'pdf',
      encoding: 'UTF-8',
      orientation: 'Portrait',
      page_size: 'A4',
      margin: { top: 20, bottom: 20, left: 15, right: 15 },
      footer: {
        right: 'Page [page] sur [topage]',
        font_size: 8
      }
    )

    send_data pdf,
              filename: "configuration_cogeli_#{Date.current}.pdf",
              type: 'application/pdf',
              disposition: 'attachment'
  end

  def send_email
    ConfigurationMailer.send_results(
      email: params[:email],
      kits: params[:kits],
      total: params[:total]
    ).deliver_later

    render json: { success: true }
  rescue => e
    render json: { success: false, error: e.message }, status: 422
  end

  private

   def get_diameter_label(code)
    { 'R1' => '80mm', 'R2' => '100mm', 'R3' => '130mm',
      'R4' => '150mm', 'R5' => '180mm', 'R6' => '80/130mm', 'R7' => '100/150mm' }[code]
  end

  def get_liaison_label(code)
    { 'R1' => 'Plafond', 'R2' => 'Traversée de mur 90°', 'R3' => 'Dans conduit' }[code]
  end

  def get_work_type_label(code)
    { 'R1' => 'Tubage', 'R2' => 'Conduit intérieur',
      'R3' => 'Conduit extérieur', 'R4' => 'Conduit concentrique' }[code]
  end

  def get_roof_label(code)
    { 'R1' => 'Conduit maçonné', 'R2' => 'Conduit métallique', 'R3' => 'Toiture terrasse',
      'R4' => 'Ardoise/tuiles plates', 'R5' => 'Tuiles', 'R6' => 'Bac acier', 'R7' => 'Création extérieur' }[code]
  end
end
