Rails.application.routes.draw do
  mount ResourceManager::Engine => "/resource_manager"
end
