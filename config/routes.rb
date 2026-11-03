Avo::Engine.routes.draw do
  root "home#index"

  get "resources", to: redirect(Avo.configuration.root_path), as: :avo_resources_redirect
  get "dashboards", to: redirect(Avo.configuration.root_path), as: :avo_dashboards_redirect

  resources :media_library, only: [:index, :show, :edit, :update, :destroy], path: "media-library" do
    get :rows, on: :member
  end
  get "attach-media", to: "media_library#attach"

  post "/rails/active_storage/direct_uploads", to: "/active_storage/direct_uploads#create"

  patch "appearance_settings", to: "appearance_settings#update"
  patch "locale", to: "locales#update", as: :locale

  scope "avo_api", as: "avo_api" do
    # Only used for searchable fields
    get "/:resource_name/search", to: "search#show"
    post "/resources/:resource_name(/:id)/attachments/", to: "attachments#create"
  end

  # Charts
  get "/:resource_name/:field_id/distribution_chart", to: "charts#distribution_chart", as: "distribution_chart"
  get "/summary/:resource_name", to: "charts#distribution_chart_full", as: "distribution_chart_full"

  get "failed_to_load", to: "home#failed_to_load"

  scope "resources", as: "resources" do
    # Generate per-resource routes (CRUD, actions, associations, attachments)
    draw(:dynamic_routes)
  end

  get "status", to: "debug#status", as: "status"
  get "updates", to: "updates#index", as: "updates"
  get "updates/progress", to: "updates#progress", as: "updates_progress"
  post "updates/run", to: "updates#run", as: "run_updates"
  post "updates/restart", to: "updates#restart", as: "restart_after_updates"
  # The old address is bookmarked and linked from released gems (avo-licensing), so it keeps its helper and redirects.
  get "avo_private/status", to: redirect("status", status: 301), as: "avo_private_status"

  if Rails.env.development? || Rails.env.staging? || Rails.env.test?
    scope "/avo_private", as: "avo_private" do
      get "/design", to: "private#design"
      get "/appearance", to: "private#appearance"
    end

    mount Lookbook::Engine, at: "/lookbook" if Avo.configuration.mount_lookbook && defined?(Lookbook)
  end
end
