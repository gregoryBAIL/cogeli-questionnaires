# app/controllers/questionnaires_controller.rb
class QuestionnairesController < ApplicationController
  def index
    # La vue index.html.erb contient tout le JS nécessaire
  end

  # API endpoint pour sauvegarder les résultats si nécessaire
  def save_results
    session_data = {
      answers: params[:answers],
      kits: params[:kits],
      total: params[:total],
      completed_at: Time.current
    }

    # Optionnel : sauvegarder en base
    if params[:save_to_db]
      @session = QuestionnaireSession.create!(
        questionnaire_id: 1,
        session_token: SecureRandom.urlsafe_base64(32),
        completed_at: Time.current,
        metadata: session_data
      )

      # Créer le résultat
      @session.create_result!(
        product_kits: params[:kits],
        generated_at: Time.current
      )
    end

    render json: { success: true, session_id: @session&.id }
  end

  # Endpoint pour générer le PDF
  def generate_pdf
    kits = params[:kits]
    total = params[:total]

    # Utiliser Prawn ou WickedPDF pour générer le PDF
    pdf = Prawn::Document.new do |pdf|
      pdf.text "Configuration Cogeli", size: 24, style: :bold
      pdf.move_down 20

      kits.each do |category, items|
        pdf.text category, size: 16, style: :bold
        pdf.move_down 10

        items.each do |item|
          pdf.text "#{item['code']} - #{item['name']}: #{item['price']}€"
        end
        pdf.move_down 15
      end

      pdf.text "Total HT: #{total}€", size: 18, style: :bold
    end

    send_data pdf.render,
              filename: "configuration_cogeli_#{Date.current}.pdf",
              type: 'application/pdf'
  end
end
