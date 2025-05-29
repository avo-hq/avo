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
    def define_namespace(namespaces, route_generator)
      if namespaces.empty?
        route_generator.call
      else
        namespace namespaces.first do
          define_namespace(namespaces[1..], route_generator)
        end
      end
    end

    define_namespace(resource.route_namespace.split("/"), route_generator)
  else
    route_generator.call
  end
end
