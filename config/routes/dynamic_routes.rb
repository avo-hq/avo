Avo::Resources::ResourceManager.fetch_resources.each do |resource|
  parts = resource.route_key.split('/').map(&:to_sym)
  last   = parts.pop

  # Build nested procs to wrap the `resources` block
  nested_block = proc do
    resources last do
      member do
        get :preview
        post :new
        put :edit

        # Associations
        get "/related/:related_name/new",            to: "/avo/associations#new",     as: :new_related,     defaults: { resource_name: resource.route_key }
        get "/related/:related_name/",               to: "/avo/associations#index",   as: :index_related,   defaults: { resource_name: resource.route_key }
        get "/related/:related_name/:related_id",    to: "/avo/associations#show",    as: :show_related,    defaults: { resource_name: resource.route_key }
        post "/related/:related_name",               to: "/avo/associations#create",  as: :create_related,  defaults: { resource_name: resource.route_key }
        delete "/related/:related_name/:related_id", to: "/avo/associations#destroy", as: :destroy_related, defaults: { resource_name: resource.route_key }
      end
    end
  end

  # Wrap namespaces inside out
  parts.reverse.each do |namespace|
    previous_block = nested_block
    nested_block = proc do
      namespace namespace, &previous_block
    end
  end

  # Evaluate the fully built proc
  instance_eval(&nested_block)
end
