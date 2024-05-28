Rails.application.routes.draw do
  devise_for :users
  root to: 'tasks#index'
  resources :groups, only: [:new, :create]
  resources :tasks, only: [:index, :new, :create]
end
