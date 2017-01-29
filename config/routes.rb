Rails.application.routes.draw do
  get 'shipments/index'

  mount ResqueWeb::Engine => '/resque_web'
  devise_for :users


  scope defaults: {format: :json} do
    namespace :api do
      namespace :v1 do
        resources :products, only: [:index]
        get 'products/:sku', to: 'products#show'
        resources :ship_methods, only: [:index]
        resources :orders, only: [:index, :show, :create, :update] do
          resources :order_items, only: [:index, :create], path: 'items'
          resources :payments, only: [:create]
          member do
            patch :submit
          end
        end
        resources :order_items, only: [:update, :destroy]
        resources :payments, only: [] do
          collection do
            get :token
          end
        end
      end
    end
  end

  resources :clients
  resources :orders do
    resources :order_items, only: [:new, :create], path: 'items'
    resources :shipments, only: [:index, :new, :create]
    member do
      patch :submit
      patch :export
      patch :manual_export
    end
    collection do
      get :export_csv
    end
  end
  resources :confirmations, only: [:show]
  resources :order_items, only: [:edit, :update, :destroy]
  resources :products
  resources :payments, only: [:index, :show]
  root to: 'pages#welcome'
end
