Rails.application.routes.draw do
  # root to: redirect("/admin")
  root to: 'home#index'
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  authenticate :user, ->(user) { user.is_admin? } do
    # mount Avo::Engine, at: '/admin/admin'
    # Avo::Engine.routes.default_scope = { path: "admin" }
    # mount Avo::Engine, at: Avo.configuration.root_path, as: :avo_app
    mount Avo::Engine, at: Avo.configuration.root_path
    scope :admin do

      scope :admin do
        get "dashboard", to: "avo/tools#dashboard"
      end
    end
  end
end
