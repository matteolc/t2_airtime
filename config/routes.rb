T2Airtime::Engine.routes.draw do
  resources :accounts, only: [:show]
  resources :countries, only: %i[index show]
  resources :operators, only: %i[index show]
  resources :products, only: [:index]
  resources :transactions, only: %i[index show]
  get "msisdn_info", to: "topups#msisdn_info"
  get "reserve_id", to: "topups#reserve_id"
  post "topup", to: "topups#topup"
end
