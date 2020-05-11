Rails.application.routes.draw do
  root 'home#index'
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # Uncomment this to enable the avocado gem
  mount Avocado::Engine => '/avocado'
end
