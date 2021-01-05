Avo::Engine.routes.draw do
  get 'hotwire', to: 'home#hotwire'
  get 'hotwire_2', to: 'home#hotwire_2'

  # root 'home#index'
  root 'home#hotwire'

  # puts ['->', Avo::App.get_available_resources].inspect
  # Avo::App.get_available_resources.each do |resource|
  #   # abort resource[:resource_name].to_sym.inspect
  #   puts '-><-'
  #   puts resource.url.pluralize.to_sym.inspect
  #   scope 'resources', as: 'resources' do
  #     resources resource.url.pluralize.to_sym, controller: 'resources'
  #   end
  # end

  scope 'resources', as: 'resources' do
    resources :projects, controller: 'resources'
    resources :users, controller: 'resources'
  end


  # get '/resources/:resource_name',          to: 'resources#index', as: 'resource'
  # post '/avo-api/:resource_name',         to: 'resources#create'
  # get '/avo-api/:resource_name/new',      to: 'resources#new'
  # get '/avo-api/:resource_name/:id',      to: 'resources#show'
  # get '/avo-api/:resource_name/:id/edit', to: 'resources#edit'
  # put '/avo-api/:resource_name/:id',      to: 'resources#update'
  # delete '/avo-api/:resource_name/:id',   to: 'resources#destroy'

  get '/avo-api/:resource_name/filters',  to: 'filters#index'

  get '/avo-api/:resource_name/actions',  to: 'actions#index'
  post '/avo-api/:resource_name/actions', to: 'actions#handle'

  get '/avo-api/search',                  to: 'search#index'
  get '/avo-api/:resource_name/search',   to: 'search#resource'

  get '/avo-api/:resource_name',          to: 'resources_old#index'
  post '/avo-api/:resource_name',         to: 'resources_old#create'
  get '/avo-api/:resource_name/new',      to: 'resources_old#new'
  get '/avo-api/:resource_name/:id',      to: 'resources_old#show'
  get '/avo-api/:resource_name/:id/edit', to: 'resources_old#edit'
  put '/avo-api/:resource_name/:id',      to: 'resources_old#update'
  delete '/avo-api/:resource_name/:id',   to: 'resources_old#destroy'

  post '/avo-api/:resource_name/:id/attach/:attachment_name/:attachment_id', to: 'relations#attach'
  post '/avo-api/:resource_name/:id/detach/:attachment_name/:attachment_id', to: 'relations#detach'

  # Tools
  get '/avo-tools/resource-overview', to: 'resource_overview#index'

  # Catch them all
  get '/:view/(:tool)/(:resource_name)/(:option)', to: 'home#index'
end
