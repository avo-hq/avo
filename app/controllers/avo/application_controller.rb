module Avo
  class ApplicationController < ::ActionController::Base
    include Pundit
    include Pagy::Backend
    protect_from_forgery with: :exception
    before_action :init_app
    before_action :set_authorization
    before_action :_authenticate!

    rescue_from Pundit::NotAuthorizedError, with: :render_unauthorized
    rescue_from ActiveRecord::RecordInvalid, with: :exception_logger

    helper_method :_current_user, :resources_path, :resource_path, :new_resource_path, :edit_resource_path, :resource_attach_path, :resource_detach_path
    add_flash_types :info, :warning, :success, :error

    def init_app
      Avo::App.boot if Avo::IN_DEVELOPMENT
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

    def _current_user
      instance_eval(&Avo.configuration.current_user)
    end

    def resources_path(model, keep_query_params: false, **args)
      return if model.nil?

      existing_params = {}

      begin
        if keep_query_params
          existing_params = Addressable::URI.parse(request.fullpath).query_values.symbolize_keys
        end
      rescue;end

      send :"resources_#{model.model_name.route_key}_path", **existing_params, **args
    end

    def resource_path(model = nil, resource_id: nil,keep_query_params: false, **args)
      existing_params = {}

      begin
        if keep_query_params
          existing_params = Addressable::URI.parse(request.fullpath).query_values.symbolize_keys
        end
      rescue;end

      return send :"resources_#{model.model_name.route_key.singularize}_path", resource_id, **args if resource_id.present?

      send :"resources_#{model.model_name.route_key.singularize}_path", model, **args
    end

    def resource_attach_path(model_name, model_id, related_name, related_id = nil)
      path = "#{Avo.configuration.root_path}/resources/#{model_name}/#{model_id}/#{related_name}/new"

      path += "/#{related_id}" if related_id.present?

      path
    end

    def resource_detach_path(model_name, model_id, related_name, related_id = nil)
      path = "#{Avo.configuration.root_path}/resources/#{model_name}/#{model_id}/#{related_name}"

      path += "/#{related_id}" if related_id.present?

      path
    end

    def new_resource_path(model, **args)
      send :"new_resources_#{model.model_name.route_key.singularize}_path", **args
    end

    def edit_resource_path(model, **args)
      send :"edit_resources_#{model.model_name.route_key.singularize}_path", model, **args
    end

    private
      def set_resource_name
        @resource_name = resource_name
      end

      def set_related_resource_name
        @related_resource_name = related_resource_name
      end

      def set_resource
        @resource = resource.hydrate(params: params)
      end

      def set_related_resource
        @related_resource = related_resource.hydrate(params: params)
      end

      def set_model
        @model = eager_load_files(@resource).find params[:id]
      end

      def set_related_model
        @related_model = eager_load_files(@related_resource).find params[:related_id]
      end

      def hydrate_resource
        @resource.hydrate(view: action_name.to_sym, user: _current_user)
      end

      def hydrate_related_resource
        @related_resource.hydrate(view: action_name.to_sym, user: _current_user)
      end

      def authorize_action
        if @model.present?
          @authorization.set_record(@model).authorize_action :index
        else
          @authorization.set_record(@resource.model_class).authorize_action :index
        end
      end

      # Get the pluralized resource name for this request
      # Ex: projects, teams, users
      # @todo: figure out a better way of getting this
      def resource_name
        return params[:resource_name] if params[:resource_name].present?

        begin
          request.path
            .match(/\/?#{Avo.configuration.root_path.gsub('/', '')}\/resources\/([a-z1-9\-_]*)\/?/mi)
            .captures
            .first
        rescue => exception
        end
      end

      def related_resource_name
        params[:related_name]
      end

      # Gets the Avo resource for this request based on the request from the `resource_name` "param"
      # Ex: Avo::Resources::Project, Avo::Resources::Team, Avo::Resources::User
      def resource
        App.get_resource @resource_name.to_s.camelize.singularize
      end

      def related_resource
        reflection = @model._reflections[params[:related_name]]

        if reflection.is_a? ::ActiveRecord::Reflection::HasOneReflection
          reflected_model = reflection.klass
        else
          reflected_model = reflection.klass
        end

        App.get_resource_by_model_name reflected_model
      end

      def eager_load_files(resource)
        if resource.attached_file_fields.present?
          resource.attached_file_fields.map(&:id).map do |field|
            return resource.model_class.send :"with_attached_#{field}"
          end
        end

        resource.model_class
      end


      # def authorize_user
      #   return if params[:controller] == 'avo/search'

      #   model = record = resource.model

      #   if ['show', 'edit', 'update'].include?(params[:action]) && params[:controller] == 'avo/resources'
      #     record = resource
      #   end

      #   # AuthorizationService::authorize_action _current_user, record, params[:action] return render_unauthorized unless
      # end

      def _authenticate!
        instance_eval(&Avo.configuration.authenticate)
      end

      def render_unauthorized(exception)
        if !exception.is_a? Pundit::NotDefinedError
          flash[:notice] = t 'avo.not_authorized'

          redirect_url = if request.referrer.blank? or request.referrer == request.url
            root_url
          else
            request.referrer
          end

          redirect_to(redirect_url)
        end
      end

      def set_authorization
        @authorization = AuthorizationService.new _current_user
      end
  end
end
