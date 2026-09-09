Rails.application.routes.draw do
  # Landing page on the root ("/") path.
  root "pages#home"

  # Devise authentication and OmniAuth callback routes for the User model.
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }, skip: [ :sessions ]
  # Disable username/password logins (`POST "/users/sign_in"`) since we only support OmniAuth.
  devise_scope :user do
    get "/users/sign_in", to: "devise/sessions#new", as: :new_user_session
    delete "/users/sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
  end

  # User-specific routes.
  authenticate :user do
    get "profile", to: "users/profile#edit"
    delete "profile", to: "users/profile#destroy"

    resources :dashboard, only: %i[ index ]
  end

  # Project and task routes.
  authenticate :user do
    resources :projects do
      resources :tasks, only: %i[ index ]
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

    namespace :coordinators do
      resources :searches, only: %i[ index create ]
    end
  end

  # Admin routes. Authorization is handled separately via CanCanCan abilities.
  authenticate :user do
    namespace :admin do
      root to: "dashboard#index"

      resource :brand, only: %i[ edit ], controller: :brand
      namespace :brand do
        resource :name, only: %i[ update ], controller: :name
        resource :logo, only: %i[ update destroy ], controller: :logo
      end

      resource :footer, only: %i[ edit ], controller: :footer
      namespace :footer do
        resource :copyright, only: %i[ update ], controller: :copyright
        resource :sitemap, only: %i[ update destroy ], controller: :sitemap
      end

      resources :legal, only: %i[ index ]

      namespace :users do
        resources :roles, only: %i[ index update ]
      end
    end
  end

  authenticate :user, ->(user) { user.admin? } do
    mount MissionControl::Jobs::Engine, at: "/admin/monitoring/jobs"
    mount ActiveStorageDashboard::Engine, at: "/admin/monitoring/storage"
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :legal, param: :slug, only: %i[ show edit update destroy ], controller: "pages/legal"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
