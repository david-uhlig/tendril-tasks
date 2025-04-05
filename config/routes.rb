Rails.application.routes.draw do
  # Defines the root path route ("/")
  root "pages#home"

  # Authenticate through devise and omniauth
  devise_for :users,
             controllers: { omniauth_callbacks: "users/omniauth_callbacks" },
             skip: [ :sessions ]

  # Disable the `POST "/users/sign_in"` route.
  # Prevents username/password logins. We only support omniauth.
  devise_scope :user do
    get "/users/sign_in", to: "devise/sessions#new", as: :new_user_session
    delete "/users/sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
  end

  resources :tasks do
    resources :applications,
              controller: "tasks/applications",
              only: [ :create, :destroy, :update ],
              param: :user_id
    patch "/applications/:user_id/status",
          to: "tasks/applications/statuses#update",
          as: :application_status
    put "/applications/:user_id/status",
        to: "tasks/applications/statuses#update",
        as: nil
  end
  get "/tasks/new/from-preset/:project_id/:coordinator_ids", to: "tasks/from_preset#new", as: :new_task_from_preset

  resources :projects do
    resources :tasks, only: %i[ index ]
  end

  namespace :coordinators do
    resources :searches, only: %i[ index create ]
  end

  resources :dashboard, only: %i[ index ]

  resources :admin, only: %i[ index ]
  namespace :admin do
    resources :legal, only: %i[ index ]
    resource :footer, only: %i[ edit ], controller: :footer
    namespace :footer do
      resource :copyright, only: %i[ update ], controller: :copyright
      resource :sitemap, only: %i[ update destroy ], controller: :sitemap
    end
    resource :brand, only: %i[ edit ], controller: :brand
    namespace :brand do
      resource :name, only: %i[ update ], controller: :name
      resource :logo, only: %i[ update destroy ], controller: :logo
    end
    namespace :users do
      resources :roles, only: %i[ index update ]
    end
  end

  get "/profile", to: "users/profile#edit"
  delete "/profile", to: "users/profile#destroy"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :legal, param: :slug, only: %i[ show edit update destroy ], controller: "pages/legal"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  authenticate :user, ->(user) { user.admin? } do
    mount MissionControl::Jobs::Engine, at: "/admin/monitoring/jobs"
  end
end
