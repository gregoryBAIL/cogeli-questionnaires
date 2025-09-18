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
    # Avec Prawn
    pdf = Prawn::Document.new do
      text "Configuration Cogeli", size: 24, style: :bold
      move_down 20

      params[:kits].each do |category, items|
        text category, size: 16, style: :bold
        move_down 10

        items.each do |item|
          text "#{item['code']} - #{item['name']}: #{item['price']}€"
        end
        move_down 15
      end

      text "Total HT: #{params[:total]}€", size: 18, style: :bold
    end

    send_data pdf.render,
              filename: "configuration_cogeli_#{Date.current}.pdf",
              type: 'application/pdf'
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
end
