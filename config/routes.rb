Rails.application.routes.draw do
  resources :readings, only: %i[create]
  get "up" => "rails/health#show", :as => :rails_health_check
  root "readings#new"
end
