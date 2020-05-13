module Avocado
  class ApplicationController < ActionController::Base
    rescue_from Exception, with: :custom_logger
    protect_from_forgery with: :exception
    before_action :init_app

    def init_app
      Avocado::App.init
    end

    def custom_logger(exception)
      exception_message = exception.message
      # exception = exception.as_json
      # abort exception.inspect
      # exception['message'] = exception_message

      return render json: exception.message
      raise exception
    end
  end
end
