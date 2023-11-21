Rails.application.routes.draw do
  root to: redirect(Avo.configuration.root_path)
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get "hey", to: "home#index"

  authenticate :user, ->(user) { user.is_admin? } do
    scope :admin do
      get "custom_tool", to: "avo/tools#custom_tool"
    end

    mount Avo::Engine, at: Avo.configuration.root_path
    # Uncomment to test constraints /123/en/admin
    # scope ":course", constraints: {course: /\w+(-\w+)*/} do
    #   scope ":locale", constraints: {locale: /\w[-\w]*/} do
    #     mount Avo::Engine, at: Avo.configuration.root_path
    #   end
    # end

    # TODO: support locale based routes
    scope "(:locale)" do
      # mount Avo::Engine, at: Avo.configuration.root_path
    end
  end
end

if defined? ::Avo
  Avo::Engine.routes.draw do
    scope :resources do
      get "courses/cities", to: "courses#cities"
      get "users/get_users", to: "users#get_users"
    end
  end
end
