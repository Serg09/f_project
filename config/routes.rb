Rails.application.routes.draw do
  devise_for :users

  resources :orders, only: [:index, :show]
  root to: 'pages#welcome'
end
