Rails.application.routes.draw do
  devise_for :admin_users, path: "admin"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "application#top"

  namespace :admin do
    root "shops#index"
    resources :shops
    resources :menus
  end

  namespace :api do
    namespace :v1 do
      resources :shops
      resources :random_menus, only: [:index]
      resource :recommended_menus, only: [:create]
    end
  end
end
