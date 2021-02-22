Avo::Engine.routes.draw do
  root 'home#index'

  get 'resources', to: redirect('/avo')

  scope 'resources', as: 'resources' do
    # Actions
    get  '/:resource_name(/:id)/actions/:action_id', to: 'actions#show'
    post '/:resource_name(/:id)/actions/:action_id', to: 'actions#handle'

    # Resources as below:
    # resources :posts, controller: 'resources', as: 'posts'
    instance_eval(&Avo::App.draw_routes)

    # Relations
    get    '/:resource_name/:id/:related_name/new',         to: 'relations#new'
    get    '/:resource_name/:id/:related_name/',            to: 'relations#index'
    get    '/:resource_name/:id/:related_name/:related_id', to: 'relations#show'
    post   '/:resource_name/:id/:related_name',             to: 'relations#create'
    delete '/:resource_name/:id/:related_name/:related_id', to: 'relations#destroy'
  end

  # get '/avo-api/search',                  to: 'search#index'
  # get '/avo-api/:resource_name/search',   to: 'search#resource'

  # Tools
  # get '/avo-tools/resource-overview', to: 'resource_overview#index'
end
