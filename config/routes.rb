Avo::Engine.routes.draw do
  root "home#index"

  get "resources", to: redirect("/avo")

  scope "resources", as: "resources" do
    # Attachments
    get "/:resource_name/:id/active_storage_attachments/:attachment_name/:signed_attachment_id", to: "attachments#show"
    delete "/:resource_name/:id/active_storage_attachments/:attachment_name/:signed_attachment_id", to: "attachments#destroy"

    # Actions
    get "/:resource_name(/:id)/actions/:action_id", to: "actions#show"
    post "/:resource_name(/:id)/actions/:action_id", to: "actions#handle"

    # Generate resource routes as below:
    # resources :posts
    instance_eval(&Avo::App.draw_routes)

    # Relations
    get "/:resource_name/:id/:related_name/new", to: "relations#new"
    get "/:resource_name/:id/:related_name/", to: "relations#index"
    get "/:resource_name/:id/:related_name/:related_id", to: "relations#show"
    post "/:resource_name/:id/:related_name", to: "relations#create"
    delete "/:resource_name/:id/:related_name/:related_id", to: "relations#destroy"
  end

  # get '/avo-api/search',                  to: 'search#index'
  # get '/avo-api/:resource_name/search',   to: 'search#resource'

  # Tools
  # get '/avo-tools/resource-overview', to: 'resource_overview#index'
end
