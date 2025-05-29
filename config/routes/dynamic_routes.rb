Avo::Resources::ResourceManager.fetch_resources.map do |resource|
  route_generator = -> {
    resources resource.route_key do
      member do
        get :preview
        post :new
        put :edit
      end
    end
  }

  if resource.route_namespace.present?
    namespace resource.route_namespace do
      route_generator.call
    end
  else
    route_generator.call
  end
end
