Rails.application.routes.draw do
  devise_for :users

  resources :orders
  resources :products
  root to: 'pages#welcome'
end
