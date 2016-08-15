Rails.application.routes.draw do
  get 'products/index'

  get 'products/show'

  get 'products/new'

  get 'products/edit'

  devise_for :users

  resources :orders, only: [:index, :show]
  resources :products
  root to: 'pages#welcome'
end
