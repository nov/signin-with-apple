Rails.application.routes.draw do
  resource :session, only: [:show, :create]
  match 'callback', to: 'sessions#callback', via: [:get, :post]
  root to: 'sessions#new'
end
