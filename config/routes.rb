# config/routes.rb
Rails.application.routes.draw do
  # Page principale (SPA)
  root "questionnaires#index"

  # API endpoints pour le SPA
  namespace :api do
    post 'save_results', to: 'questionnaires#save_results'
    post 'generate_pdf', to: 'questionnaires#generate_pdf'
    get 'product_kits', to: 'product_kits#index'
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
