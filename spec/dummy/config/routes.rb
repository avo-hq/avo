Rails.application.routes.draw do
  root to: redirect(Avo.configuration.root_path)
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  authenticate :user, ->(user) { user.is_admin? } do
    scope :admin do
      get "dashboard", to: "avo/tools#dashboard"
    end

    mount Avo::Engine, at: Avo.configuration.root_path
  end
end
