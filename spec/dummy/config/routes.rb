Rails.application.routes.draw do
  root to: redirect('/avo')
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  authenticate :user, -> user { user.is_admin? } do
    mount Avo::Engine => Avo.configuration.root_path
  end
end
