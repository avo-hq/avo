Avocado::Engine.routes.draw do
  root 'home#index'

  get '/avocado-api/:resource_name', to: 'resources#index'
  post '/avocado-api/:resource_name', to: 'resources#create'
  get '/avocado-api/:resource_name/fields', to: 'resources#fields'
  get '/avocado-api/:resource_name/:id', to: 'resources#show'
  put '/avocado-api/:resource_name/:id', to: 'resources#update'
  delete '/avocado-api/:resource_name/:id', to: 'resources#destroy'

  get '/:view/(:tool)/(:resource_name)/(:option)', to: 'home#index'
end
