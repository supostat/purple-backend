Rails.application.routes.draw do
  default_url_options :host => ENV["HTTP_HOST"] || "localhost:8080"
  devise_for :users,
    skip: [:passwords],
    skip: [:invitation],
    defaults: {format: :json},
    path: "",
    path_names: {
      sign_in: "login",
      sign_out: "logout",
      registration: "signup",
    },
    controllers: {
      sessions: "sessions",
      registrations: "registrations",
    }

  as :user do
    get "reset-password", :to => "devise/passwords#edit"
    get "accept-invite/:token", :to => "devise/invitations#edit", :as => "accept_invite"
  end

  namespace :api do
    namespace :v1 do
      resources :tests, only: [:index]
      resources :invites, only: [:index, :create] do
        member do
          post :revoke
        end
      end

      resource :passwords, only: [:index] do
        collection do
          post :send_reset_password_email
          post :reset_password
        end
      end

      resources :users, only: [:index, :show] do
        member do
          get :history
          post :update_personal_details
          post :update_access_details
          post :disable
          post :enable
        end
      end

      resources :accept_invites, only: [:index] do
        collection do
          post :accept
        end
      end
    end
  end
end
