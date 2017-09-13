T2Airtime::Engine.routes.draw do
    get '/account', to: 'airtime#account'
    get '/countries', to: 'airtime#countries'
    get '/countries/:id/operators', to: 'airtime#operators'
    get '/countries/:country_id/operators/:id/products', to: 'airtime#products'
    get '/transactions', to: 'airtime#transactions'
    get '/transactions/:id', to: 'airtime#transaction'        
end
