module Avo
  class ApplicationController < ActionController::Base
    include Pundit
    rescue_from ActiveRecord::RecordInvalid, with: :exception_logger
    protect_from_forgery with: :exception
    before_action :init_app

    def init_app
      Avo::App.init
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

    private
      def resource_model
        avo_resource.model
      end

      def avo_resource
        App.get_resource params[:resource_name].to_s.camelize.singularize
      end
  end
end
