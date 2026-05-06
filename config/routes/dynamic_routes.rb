sorted_resources = Avo::Resources::ResourceManager.fetch_resources
  .sort_by { |r| [-r.route_path.count("/"), r.route_path] }

sorted_resources.each do |resource|
  # `defaults` sets `params[:resource_name]` for incoming requests; `constraints`
  # makes the param part of the route's identity so url_for(params) picks the
  # correct route per resource (otherwise Rails would pick the first matching
  # controller/action across all per-resource routes).
  defaults resource_name: resource.route_key do
    constraints resource_name: resource.route_key do
      # Actions are declared BEFORE `resources` so that paths like `/users/actions`
      # are not shadowed by the show route (`/users/:id`) which would match
      # `:id = "actions"`.
      scope resource.route_path, as: resource.route_key do
        get "(/:id)/actions/(:action_id)", to: "actions#show", as: "actions_show"
        post "(/:id)/actions/(:action_id)", to: "actions#handle", as: "actions_handle"
      end

      resources resource.route_key,
        path: resource.route_path,
        controller: resource.controller_path do
        get :search, on: :collection
        get :association_search, on: :collection

        member do
          get :preview
          post :new
          put :edit
        end
      end

      # Associations and attachments are declared AFTER `resources` so that the
      # 2-segment associations index pattern (`:id/:related_name/`) does not
      # shadow `:id/edit`, `:id/preview`, etc.
      scope resource.route_path, as: resource.route_key do
        # Associations
        get ":id/:related_name/new", to: "associations#new", as: "associations_new"
        get ":id/:related_name/", to: "associations#index", as: "associations_index"
        get ":id/:related_name/:related_id", to: "associations#show", as: "associations_show"
        post ":id/:related_name", to: "associations#create", as: "associations_create"
        delete ":id/:related_name/:related_id", to: "associations#destroy", as: "associations_destroy"

        # Attachments
        delete ":id/active_storage_attachments/:attachment_name/:attachment_id", to: "attachments#destroy", as: "attachments_destroy"
      end
    end
  end
end
