Avo::Engine.routes.draw do
  root "home#index"

  get "resources", to: redirect("/admin")
  post "/rails/active_storage/direct_uploads", to: "/active_storage/direct_uploads#create"

  scope "avo_api", as: "avo_api" do
    get "/search", to: "search#index"
    get "/:resource_name/search", to: "search#show"
    post "/resources/:resource_name/:id/attachments/", to: "attachments#create"
  end

  get "failed_to_load", to: "home#failed_to_load"

  scope "resources", as: "resources" do
    # Attachments
    get "/:resource_name/:id/active_storage_attachments/:attachment_name/:signed_attachment_id", to: "attachments#show"
    delete "/:resource_name/:id/active_storage_attachments/:attachment_name/:signed_attachment_id", to: "attachments#destroy"

    # Ordering
    patch "/:resource_name/:id/order", to: "resources#order"

    # Actions
    get "/:resource_name(/:id)/actions/:action_id", to: "actions#show"
    post "/:resource_name(/:id)/actions/:action_id", to: "actions#handle"

    # Generate resource routes as below:
    # resources :posts
    Avo::DynamicRouter::routes(self)

    # Relations
    get "/:resource_name/:id/:related_name/new", to: "relations#new", as: "associations_new"
    get "/:resource_name/:id/:related_name/", to: "relations#index", as: "associations_index"
    get "/:resource_name/:id/:related_name/:related_id", to: "relations#show", as: "associations_show"
    post "/:resource_name/:id/:related_name", to: "relations#create", as: "associations_create"
    delete "/:resource_name/:id/:related_name/:related_id", to: "relations#destroy", as: "associations_destroy"
  end
end
