Avo::Engine.routes.draw do
  root 'home#index'

  get '/avo-api/search',                  to: 'resources#search'
  get '/avo-api/:resource_name/search',   to: 'resources#search'
  get '/avo-api/:resource_name',          to: 'resources#index'
  get '/avo-api/:resource_name/filters',  to: 'resources#filters'
  post '/avo-api/:resource_name',         to: 'resources#create'
  get '/avo-api/:resource_name/fields',   to: 'resources#fields'
  get '/avo-api/:resource_name/:id',      to: 'resources#show'
  get '/avo-api/:resource_name/:id/edit', to: 'resources#edit'
  put '/avo-api/:resource_name/:id',      to: 'resources#update'
  delete '/avo-api/:resource_name/:id',   to: 'resources#destroy'
  post '/avo-api/:resource_name/:id/attach/:attachment_name/:attachment_id', to: 'resources#attach'
  post '/avo-api/:resource_name/:id/detach/:attachment_name/:attachment_id', to: 'resources#detach'

  # Tools
  get '/avo-tools/resource-overview', to: 'resource_overview#index'

  # Catch them all
  get '/:view/(:tool)/(:resource_name)/(:option)', to: 'home#index'
end
