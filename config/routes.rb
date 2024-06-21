Rails.application.routes.draw do
  root "sessions#show"

  resource :session

  get "up" => "rails/health#show", as: :rails_health_check
end
