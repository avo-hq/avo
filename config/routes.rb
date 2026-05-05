Avo::Engine.routes.draw do
  root "home#index"

  get "resources", to: redirect(Avo.configuration.root_path), as: :avo_resources_redirect
  get "dashboards", to: redirect(Avo.configuration.root_path), as: :avo_dashboards_redirect

  resources :media_library, only: [:index, :show, :update, :destroy], path: "media-library"
  get "attach-media", to: "media_library#attach"

  post "/rails/active_storage/direct_uploads", to: "/active_storage/direct_uploads#create"

  scope "avo_api", as: "avo_api" do
    # Only used for searchable fields
    get "/:resource_name/search", to: "search#show"
    post "/resources/:resource_name/:id/attachments/", to: "attachments#create"
  end

  # Charts
  get "/:resource_name/:field_id/distribution_chart", to: "charts#distribution_chart", as: "distribution_chart"

  get "failed_to_load", to: "home#failed_to_load"

  scope "resources", as: "resources" do
    # Generate per-resource routes (CRUD, actions, associations, attachments)
    draw(:dynamic_routes)
  end

  scope "/avo_private", as: "avo_private" do
    get "/status", to: "debug#status", as: "status"
  end

  if Rails.env.development? || Rails.env.staging? || Rails.env.test?
    scope "/avo_private", as: "avo_private" do
      get "/design", to: "private#design"
    end

    mount Lookbook::Engine, at: "/lookbook" if defined?(Lookbook)
  end
end
