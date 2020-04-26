Avocado::Engine.routes.draw do
  root 'home#index'

  get '/avocado-api/:resource/', to: 'resources#index'
  get '/avocado-api/:resource/:id', to: 'resources#show'

  get '/:view/(:tool)/(:resource)/(:option)', to: 'home#index'
end
