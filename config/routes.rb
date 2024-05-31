Rails.application.routes.draw do
  devise_for :users
  root to: 'tasks#index'
  resources :groups, only: [:new, :create, :show, :update]
  resources :tasks, only: [:index, :new, :create, :show, :update] do
    resources :finishes, only: [:create, :destroy]
  end
end
