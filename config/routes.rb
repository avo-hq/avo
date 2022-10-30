Avo::Engine.routes.draw do
  root "home#index"

  get "resources", to: redirect(Avo.configuration.root_path)
  get "dashboards", to: redirect(Avo.configuration.root_path)

  post "/rails/active_storage/direct_uploads", to: "/active_storage/direct_uploads#create"

  resources :dashboards do
    resources :cards, controller: "dashboards/cards"
  end

  scope "avo_api", as: "avo_api" do
    get "/search", to: "search#index"
    get "/:resource_name/search", to: "search#show"
    post "/resources/:resource_name/:id/attachments/", to: "attachments#create"
  end

  # Records ordering
  scope "reorder", as: "reorder" do
    patch "/:resource_name/:id", to: "reorder#order", as: "order"
  end

  get "failed_to_load", to: "home#failed_to_load"

  scope "resources", as: "resources" do
    # Attachments
    delete "/:resource_name/:id/active_storage_attachments/:attachment_name/:attachment_id", to: "attachments#destroy"

    # Actions
    get "/:resource_name(/:id)/actions/:action_id", to: "actions#show"
    post "/:resource_name(/:id)/actions/:action_id", to: "actions#handle"

    # Generate resource routes as below:
    # resources :posts
    Avo::DynamicRouter.routes

    # Associations
    get "/:resource_name/:id/:related_name/new", to: "associations#new", as: "associations_new"
    get "/:resource_name/:id/:related_name/", to: "associations#index", as: "associations_index"
    get "/:resource_name/:id/:related_name/:related_id", to: "associations#show", as: "associations_show"
    post "/:resource_name/:id/:related_name", to: "associations#create", as: "associations_create"
    delete "/:resource_name/:id/:related_name/:related_id", to: "associations#destroy", as: "associations_destroy"
  end

  scope "/avo_private", as: "avo_private" do
    get "/debug", to: "debug#index", as: "debug_index"
    get "/debug/report", to: "debug#report", as: "debug_report"
    post "/debug/refresh_license", to: "debug#refresh_license"
  end

  if Rails.env.development? || Rails.env.staging?
    scope "/avo_private", as: "avo_private" do
      get "/design", to: "private#design"
    end
  end
end
