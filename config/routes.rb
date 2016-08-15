Rails.application.routes.draw do
  devise_for :users

  resources :orders, only: [:index, :show]
  resources :products
  root to: 'pages#welcome'
end
