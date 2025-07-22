Avo::Resources::ResourceManager.fetch_resources.map do |resource|
  resources resource.route_key do
    get :search, on: :collection

    member do
      get :preview
      post :new
      put :edit
    end
  end
end
