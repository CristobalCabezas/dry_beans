Rails.application.routes.draw do
  get '/routes', to: 'routes#index'
  get '/routes/:id', to: 'routes#show'
  post '/routes', to: 'routes#create'
  get '/delivery_events', to: 'delivery_events#index'
  post '/delivery_events', to: 'delivery_events#create'
end
