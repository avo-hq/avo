module Avo
  class ApplicationController < ActionController::Base
    rescue_from ActiveRecord::RecordInvalid, with: :exception_logger
    protect_from_forgery with: :exception
    before_action :init_app

    def init_app
      Avo::App.boot unless Rails.env.production?
      Avo::App.init request

      @license = Avo::App.license
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
      def resource
        eager_load_files(resource_model).find params[:id]
      end

      def eager_load_files(query)
        if avo_resource.attached_file_fields.present?
          avo_resource.attached_file_fields.map(&:id).map do |field|
            query = query.send :"with_attached_#{field}"
          end
        end

        query
      end

      def resource_model
        avo_resource.model
      end

      def avo_resource
        App.get_resource params[:resource_name].to_s.camelize.singularize
      end

      def authorize_user
        return if params[:controller] == 'avo/search'

        model = record = avo_resource.model

        if ['show', 'edit', 'update'].include?(params[:action]) && params[:controller] == 'avo/resources'
          record = resource
        end

        return render_unauthorized unless AuthorizationService::authorize_action current_user, record, params[:action]
      end

      def render_unauthorized
        render json: { message: 'Unauthorized' }, status: 403
      end
  end
end
