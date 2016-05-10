Rails.application.routes.draw do
  get 'orders/index'

  get 'orders/show'

  devise_for :users

  resources :orders, only: [:index]
  root to: 'pages#welcome'
end
