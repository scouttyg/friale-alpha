require "sidekiq/web"

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

      resources :accounts, only: [:index, :show] do
        member do
          post :switch
          get :settings, to: 'accounts#edit'
          namespace 'settings' do
            resources :billings, path: 'billing' do
              collection do
                get '/', to: redirect { |_params, req| "#{req.path}/overview" }
                get :plan
                get :overview
                resources :subscriptions, only: [:new, :create], controller: 'billings/subscriptions' do
                  collection do
                    delete :cancel
                  end
                end
              end
            end

            resources :payment_methods, only: [:index, :create, :destroy] do
              member do
                patch :make_default
              end
            end

            resources :members
          end
          post :settings, to: 'accounts#update', as: :update_settings
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

  get 'invitations/:token', to: 'invitations#show', as: :invitation
  post 'invitations/:token/accept', to: 'invitations#accept', as: :accept_invitation
  post 'invitations/:token/decline', to: 'invitations#decline', as: :decline_invitation

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
