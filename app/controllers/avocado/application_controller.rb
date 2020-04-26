module Avocado
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    before_action :init_app

    def init_app
      Avocado::App.init
    end
  end
end
