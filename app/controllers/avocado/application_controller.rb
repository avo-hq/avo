module Avocado
  class ApplicationController < ActionController::Base
    rescue_from ActiveRecord::RecordInvalid, with: :exception_logger
    protect_from_forgery with: :exception
    before_action :init_app

    def init_app
      Avocado::App.init
    end

    def exception_logger(exception)
      respond_to do |format|
        format.html { raise exception }
        format.json { render json: {
          errors: exception.record.present? ? exception.record.errors : [],
          message: exception.message,
          traces: exception.backtrace,
        }, status: ActionDispatch::ExceptionWrapper.status_code_for_exception(exception.class.name) }
      end
    end
  end
end
