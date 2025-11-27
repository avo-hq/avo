Rails.application.routes.draw do
  root to: redirect(Avo.configuration.root_path)
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get "hey", to: "home#index"

  resources :posts

  authenticate :user, ->(user) { user.is_admin? } do
    mount_avo do
      scope :resources do
        get "courses/cities", to: "courses#cities"
        get "users/get_users", to: "users#get_users"
      end

      put "switch_accounts/:id", to: "switch_accounts#update", as: :switch_account

      get "custom_tool", to: "tools#custom_tool", as: :custom_tool
    end

    # Uncomment to test constraints /123/en/admin
    # scope ":course", constraints: {course: /\w+(-\w+)*/} do
    #   scope ":locale", constraints: {locale: /\w[-\w]*/} do
    #     mount_avo
    #   end
    # end

    # TODO: support locale based routes
    scope "(:locale)" do
      # mount_avo
    end
  end
end
