Avo::Engine.routes.draw do
  root "home#index"

  get "resources", to: redirect(Avo.configuration.root_path), as: :avo_resources_redirect
  get "dashboards", to: redirect(Avo.configuration.root_path), as: :avo_dashboards_redirect

  resources :media_library, only: [:index, :show, :update, :destroy], path: "media-library"
  get "attach-media", to: "media_library#attach"

  post "/rails/active_storage/direct_uploads", to: "/active_storage/direct_uploads#create"

  scope "avo_api", as: "avo_api" do
    get "/search", to: "search#index"
    get "/:resource_name/search", to: "search#show"
    post "/resources/:resource_name/:id/attachments/", to: "attachments#create"
  end

  # Charts
  get "/:resource_name/:field_id/distribution_chart", to: "charts#distribution_chart", as: "distribution_chart"

  get "failed_to_load", to: "home#failed_to_load"

  scope "resources", as: "resources" do
    # Attachments
    delete "/:resource_name/:id/active_storage_attachments/:attachment_name/:attachment_id", to: "attachments#destroy"

    # Actions
    get "/:resource_name(/:id)/actions/(:action_id)", to: "actions#show"
    post "/:resource_name(/:id)/actions/(:action_id)", to: "actions#handle"

    # Generate resource routes as below:
    # resources :posts
    draw(:dynamic_routes)
  end

  scope "/avo_private", as: "avo_private" do
    get "/status", to: "debug#status", as: "status"
    post "/status/send_to_hq", to: "debug#send_to_hq", as: "send_to_hq"
    get "/debug/report", to: "debug#report", as: "debug_report"
    post "/debug/refresh_license", to: "debug#refresh_license"
  end

  if Rails.env.development? || Rails.env.staging?
    scope "/avo_private", as: "avo_private" do
      get "/design", to: "private#design"
    end

    mount Lookbook::Engine, at: "/lookbook" if defined?(Lookbook)
  end
end
