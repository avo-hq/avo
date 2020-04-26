Avocado::Engine.routes.draw do
  root 'home#index'

  get '/avocado-api/:resource_name/', to: 'resources#index'
  get '/avocado-api/:resource_name/:id', to: 'resources#show'
  put '/avocado-api/:resource_name/:id', to: 'resources#update'
  get '/avocado-api/:resource_name/:id/fields', to: 'resources#fields'

  get '/:view/(:tool)/(:resource_name)/(:option)', to: 'home#index'
end
