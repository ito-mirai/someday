Rails.application.routes.draw do
  devise_for :users
  root to: 'tasks#index'
  resources :groups, only: [:index, :create, :show, :update, :destroy]
  resources :tasks, only: [:index, :create, :show, :update, :destroy] do
    resources :finishes, only: [:create, :destroy]
  end
  resources :messages, only: [:new, :create, :update, :destroy]
end
