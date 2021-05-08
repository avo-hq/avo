Rails.application.routes.draw do
  mount Avo::Engine => Avo.configuration.root_path
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
