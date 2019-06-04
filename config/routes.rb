Rails.application.routes.draw do
  resource :session, only: [:show, :create, :destroy]
  get 'callback', to: 'sessions#create'
  root to: 'sessions#new'
end
