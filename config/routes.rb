Avocado::Engine.routes.draw do
  root 'home#index'

  get '/avocado-api/search',                  to: 'resources#search'
  get '/avocado-api/:resource_name/search',   to: 'resources#search'
  get '/avocado-api/:resource_name',          to: 'resources#index'
  get '/avocado-api/:resource_name/filters',  to: 'resources#filters'
  post '/avocado-api/:resource_name',         to: 'resources#create'
  get '/avocado-api/:resource_name/fields',   to: 'resources#fields'
  get '/avocado-api/:resource_name/:id',      to: 'resources#show'
  get '/avocado-api/:resource_name/:id/edit', to: 'resources#edit'
  put '/avocado-api/:resource_name/:id',      to: 'resources#update'
  delete '/avocado-api/:resource_name/:id',   to: 'resources#destroy'
  post '/avocado-api/:resource_name/:id/attach/:attachment_name/:attachment_id', to: 'resources#attach'
  post '/avocado-api/:resource_name/:id/detach/:attachment_name/:attachment_id', to: 'resources#detach'

  get '/:view/(:tool)/(:resource_name)/(:option)', to: 'home#index'
end
