Rails.application.routes.draw do
  devise_for :users,
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

  namespace :api do
    namespace :v1 do
      resources :tests, only: [:index]
      resources :invites, only: [:index, :create]
      resource :passwords, only: [:index] do
        collection do
          post :send_reset_password_email
          post :reset_password
        end
      end
      resources :users, only: [:index, :show] do
        member do
          get :history
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
