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
      resources :invites, only: [:index]
      resources :users, only: [:index]
      resources :accept_invites, only: [:index] do
        collection do
          post :accept
        end
      end
    end
  end
end
