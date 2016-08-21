Rails.application.routes.draw do
  get 'order_items/new'

  get 'order_items/edit'

  devise_for :users

  resources :clients
  resources :orders do
    resources :order_items, only: [:new, :create]
  end
  resources :order_items, only: [:edit, :update, :destroy]
  resources :products
  root to: 'pages#welcome'
end
