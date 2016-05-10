Rails.application.routes.draw do
  devise_for :users

  resources :orders, only: [:index]
  root to: 'pages#welcome'
end
