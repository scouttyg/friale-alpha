require 'sidekiq/web'

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords",
    confirmations: "users/confirmations"
  }

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  authenticated :admin_user do
    mount Sidekiq::Web => "/sidekiq"
  end

  authenticated :user do
    scope module: :dashboard do
      root to: "example#index", as: :authenticated_root

      resources :notifications do
        member do
          patch :mark_as_read
          patch :mark_as_unread
        end
        collection do
          patch :mark_all_as_read
          get :dropdown_content
        end
      end
    end
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  root to: "pages#home"
  get "contact", to: "pages#contact"
  post "contact", to: "pages#contact_post", as: :contact_post
  get "about", to: "pages#about"
  get "pricing", to: "pages#pricing"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
