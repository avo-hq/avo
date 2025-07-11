Avo::Resources::ResourceManager.fetch_resources.map do |resource|
  resources resource.route_key do
    member do
      get :preview
      post :new
      put :edit
    end
  end
end
