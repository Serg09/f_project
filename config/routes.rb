Rails.application.routes.draw do
  mount ResqueWeb::Engine => '/resque_web'
  devise_for :users

  resources :clients
  resources :orders do
    resources :order_items, only: [:new, :create]
    member do
      patch :submit
      patch :export
    end
  end
  resources :order_items, only: [:edit, :update, :destroy]
  resources :products
  root to: 'pages#welcome'
end
