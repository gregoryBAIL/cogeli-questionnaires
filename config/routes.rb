Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Root route
  root "questionnaires#index"

  # Questionnaires routes
  resources :questionnaires, only: [:index, :show] do
    member do
      post :start
    end
  end

  # Questions routes
  resources :questions, param: :id, only: [:show] do
    member do
      post :answer
      post :previous
    end
  end

  # Results routes
  get "results", to: "results#show"
  get "results/download", to: "results#download"
  post "results/email", to: "results#email"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA files
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
