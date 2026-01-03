Rails.application.routes.draw do
  devise_for :admin_users, path: "admin"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "application#top"

  namespace :api do
    namespace :v1 do
      resources :shops, only: [:index, :show, :create]
      resources :menu_with_shops, only: [:show]
      resources :random_menus, only: [:index]
      resource :recommended_menus, only: [:create]

      # Google OAuth
      post "/auth/google", to: "auth#google"

      namespace :admin do
        resource :auth, only: [:create, :destroy], controller: "authentication"
        resources :shops
        resources :menus
        resources :genres, only: [:index]
        resources :soups, only: [:index]
        resources :noodles, only: [:index]
      end
    end
  end
end
