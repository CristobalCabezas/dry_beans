Rails.application.routes.draw do
  get '/routes', to: 'routes#index'
  get '/routes/:id', to: 'routes#show'
  post '/routes', to: 'routes#create'
  get '/routes/:route_id/trips', to: 'trips#show'
  post '/routes/:route_id/trips', to: 'trips#create'
  get '/trips/:trip_id/delivery_events', to: 'delivery_events#show'
  post '/trips/:trip_id/delivery_events', to: 'delivery_events#create'
end
