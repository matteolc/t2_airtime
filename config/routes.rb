T2Airtime::Engine.routes.draw do
  resources :accounts, only: [:show]
  resources :countries, only: %i[index show]
  resources :operators, only: %i[index show]
  resources :products, only: [:index]
  resources :transactions, only: %i[index show]
end
