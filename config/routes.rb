Avo::Engine.routes.draw do
  root 'home#index'

  get '/avo-api/:resource_name/filters',  to: 'filters#index'

  get '/avo-api/:resource_name/actions',  to: 'actions#index'
  post '/avo-api/:resource_name/actions', to: 'actions#handle'

  get '/avo-api/search',                  to: 'search#index'
  get '/avo-api/:resource_name/search',   to: 'search#resource'

  get '/avo-api/:resource_name',          to: 'resources#index'
  post '/avo-api/:resource_name',         to: 'resources#create'
  get '/avo-api/:resource_name/new',      to: 'resources#new'
  get '/avo-api/:resource_name/:id',      to: 'resources#show'
  get '/avo-api/:resource_name/:id/edit', to: 'resources#edit'
  put '/avo-api/:resource_name/:id',      to: 'resources#update'
  delete '/avo-api/:resource_name/:id',   to: 'resources#destroy'

  post '/avo-api/:resource_name/:id/attach/:attachment_name/:attachment_id', to: 'relations#attach'
  post '/avo-api/:resource_name/:id/detach/:attachment_name/:attachment_id', to: 'relations#detach'

  # Tools
  get '/avo-tools/resource-overview', to: 'resource_overview#index'

  # Catch them all
  get '/:view/(:tool)/(:resource_name)/(:option)', to: 'home#index'
end
