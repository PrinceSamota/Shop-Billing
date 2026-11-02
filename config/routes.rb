Rails.application.routes.draw do
  root "dashboard#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
  resources :products
  resources :customers do
    resources :customer_payments, only: [:create]

    member do
      get :bills, to: "customers#bills"
    end
    
    collection do
      get :export
    end

  end
  resources :library_students do
    member do
      patch :mark_left
      patch :mark_active
    end

    resources :library_payments, only: [:new, :create]
  end

  get "library", to: "library_students#index", as: :library
  resources :bills do
    post :send_bill_email, on: :member
  end
  resources :suppliers do
    resources :supplier_entries, only: [:create]
  end
end
