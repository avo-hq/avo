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

  # get '/resources/:resource_name(/:id)/actions/', to: 'actions#index'
  # get '/resources/:resource_name(/:id)/actions/:action_id/show', to: 'actions#show'
  # post '/resources/:resource_name(/:id)/actions/:action_id/show', to: 'actions#show'
  get '/resources/:resource_name(/:id)/actions/:action_id', to: 'actions#show'
  post '/resources/:resource_name(/:id)/actions/:action_id', to: 'actions#handle'
  # get '/actions/:action_id', to: 'actions#frame'

  get 'resources', to: redirect('/avo')
  scope 'resources', as: 'resources' do
    resources :posts, controller: 'resources', as: 'posts'
    resources :projects, controller: 'resources', as: 'projects'
    resources :users, controller: 'resources', as: 'users'
    resources :teams, controller: 'resources', as: 'teams'
    resources :team_memberships, controller: 'resources', as: 'team_memberships'

    get    '/:resource_name/:id/:attachment_name', to: 'relations#show'
    post   '/:resource_name/:id/:attachment_name', to: 'relations#attach'
    # post   '/:resource_name/:id/:attachment_name/:attachment_id', to: 'relations#attach'
    delete '/:resource_name/:id/:attachment_name/:attachment_id', to: 'relations#detach'
    # delete '/teams/:id/admin/:attachment_id', to: 'relations#detach'
  end



  # get '/avo-api/:resource_name/filters',  to: 'filters#index'

  # get '/avo-api/:resource_name/actions',  to: 'actions#index'
  # post '/avo-api/:resource_name/actions', to: 'actions#handle'

  get '/avo-api/search',                  to: 'search#index'
  get '/avo-api/:resource_name/search',   to: 'search#resource'

  # get '/avo-api/:resource_name',          to: 'resources_old#index'
  # post '/avo-api/:resource_name',         to: 'resources_old#create'
  # get '/avo-api/:resource_name/new',      to: 'resources_old#new'
  # get '/avo-api/:resource_name/:id',      to: 'resources_old#show'
  # get '/avo-api/:resource_name/:id/edit', to: 'resources_old#edit'
  # put '/avo-api/:resource_name/:id',      to: 'resources_old#update'
  # delete '/avo-api/:resource_name/:id',   to: 'resources_old#destroy'

  # post '/avo-api/:resource_name/:id/attach/:attachment_name/:attachment_id', to: 'relations#attach'
  # post '/avo-api/:resource_name/:id/detach/:attachment_name/:attachment_id', to: 'relations#detach'

  # Tools
  # get '/avo-tools/resource-overview', to: 'resource_overview#index'
end
