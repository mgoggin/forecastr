Rails.application.routes.draw do
  resources :readings, only: %i[new create]
  get "up" => "rails/health#show", :as => :rails_health_check
  root "home#show"
end
