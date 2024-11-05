Rails.application.routes.draw do
  resources :tasks, only: [ :index, :new ]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "pages#home"

  # Authenticate through devise and omniauth
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" },
             skip: [ :sessions ]

  # Disable the `POST "/users/sign_in"` route.
  # Prevents username/password logins. We only support omniauth.
  devise_scope :user do
    get "/users/sign_in", to: "devise/sessions#new", as: :new_user_session
    delete "/users/sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
  end

  get "/profile", to: "users/profile#edit"
  delete "/profile", to: "users/profile#destroy"


  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
