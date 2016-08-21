Rails.application.routes.draw do
  devise_for :users

  resources :clients
  resources :orders do
    resources :order_items, only: [:new, :create]
  end
  resources :products
  root to: 'pages#welcome'
end
