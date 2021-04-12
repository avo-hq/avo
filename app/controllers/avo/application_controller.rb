module Avo
  class ApplicationController < ::ActionController::Base
    include Pundit
    include Pagy::Backend
    protect_from_forgery with: :exception
    before_action :init_app
    before_action :check_avo_license
    before_action :set_authorization
    before_action :_authenticate!
    before_action :set_container_classes
    before_action :add_initial_breadcrumbs

    rescue_from Pundit::NotAuthorizedError, with: :render_unauthorized
    rescue_from ActiveRecord::RecordInvalid, with: :exception_logger

    helper_method :_current_user, :resources_path, :resource_path, :new_resource_path, :edit_resource_path, :resource_attach_path, :resource_detach_path, :related_resources_path
    add_flash_types :info, :warning, :success, :error

    def init_app
      Avo::App.init request: request, context: context

      @license = Avo::App.license
    end

    def exception_logger(exception)
      respond_to do |format|
        format.html { raise exception }
        format.json {
          render json: {
            errors: exception.respond_to?(:record) && exception.record.present? ? exception.record.errors : [],
            message: exception.message,
            traces: exception.backtrace
          }, status: ActionDispatch::ExceptionWrapper.status_code_for_exception(exception.class.name)
        }
      end
    end

    def render(*args)
      raise Avo::LicenseVerificationTemperedError, "License verification mechanism tempered with." unless method(:check_avo_license).source_location.first.match?(/.*\/app\/controllers\/avo\/application_controller\.rb/)

      super(*args)
    end

    def check_avo_license
      unless on_root_path || on_resources_path
        if @license.invalid? || @license.lacks(:custom_tools)
          if Rails.env.development?
            @custom_tools_alert_visible = true
          else
            raise Avo::LicenseInvalidError, "Your license is invalid or doesn't support custom tools."
          end
        end
      end
    end

    def _current_user
      instance_eval(&Avo.configuration.current_user)
    end

    def context
      instance_eval(&Avo.configuration.context)
    end

    def resources_path(model, keep_query_params: false, **args)
      return if model.nil?

      existing_params = {}

      begin
        if keep_query_params
          existing_params = Addressable::URI.parse(request.fullpath).query_values.symbolize_keys
        end
      rescue; end
      avo.send :"resources_#{model.model_name.route_key}_path", **existing_params, **args
    end

    def related_resources_path(parent_model, model, keep_query_params: false, **args)
      return if model.nil?

      existing_params = {}

      begin
        if keep_query_params
          existing_params = Addressable::URI.parse(request.fullpath).query_values.symbolize_keys
        end
      rescue; end
      Addressable::Template.new("#{Avo.configuration.root_path}/resources/#{@parent_resource.model.model_name.route_key}/#{@parent_resource.model.id}/#{@resource.route_key}{?query*}")
        .expand({query: {**existing_params, **args}})
        .to_str
    end

    def resource_path(model = nil, resource_id: nil, keep_query_params: false, **args)
      return avo.send :"resources_#{model.model_name.route_key.singularize}_path", resource_id, **args if resource_id.present?

      avo.send :"resources_#{model.model_name.route_key.singularize}_path", model, **args
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
      avo.send :"new_resources_#{model.model_name.route_key.singularize}_path", **args
    end

    def edit_resource_path(model, **args)
      avo.send :"edit_resources_#{model.model_name.route_key.singularize}_path", model, **args
    end

    private

    def set_resource_name
      @resource_name = resource_name
    end

    def set_related_resource_name
      @related_resource_name = related_resource_name
    end

    def set_resource
      raise ActionController::RoutingError.new "No route matches" if resource.nil?

      @resource = resource.hydrate(params: params)
    end

    def set_related_resource
      @related_resource = related_resource.hydrate(params: params)
    end

    def set_model
      @model = eager_load_files(@resource, @resource.model_class).find params[:id]
    end

    def set_related_model
      @related_model = eager_load_files(@related_resource, @related_resource.model_class).find params[:related_id]
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
    def resource_name
      return params[:resource_name] if params[:resource_name].present?

      return controller_name if controller_name.present?

      begin
        request.path
          .match(/\/?#{Avo.configuration.root_path.delete('/')}\/resources\/([a-z1-9\-_]*)\/?/mi)
          .captures
          .first
      rescue
      end
    end

    def related_resource_name
      params[:related_name]
    end

    # Gets the Avo resource for this request based on the request from the `resource_name` "param"
    # Ex: Avo::Resources::Project, Avo::Resources::Team, Avo::Resources::User
    def resource
      resource = App.get_resource @resource_name.to_s.camelize.singularize

      return resource if resource.present?

      App.get_resource_by_controller_name @resource_name
    end

    def related_resource
      reflection = @model._reflections[params[:related_name]]

      reflected_model = reflection.klass

      App.get_resource_by_model_name reflected_model
    end

    def eager_load_files(resource, query)
      if resource.attached_file_fields.present?
        resource.attached_file_fields.map do |field|
          attachment = case field.class.to_s
          when "Avo::Fields::FileField"
            "attachment"
          when "Avo::Fields::FilesField"
            "attachments"
          else
            "attachment"
          end

          return query.eager_load "#{field.id}_#{attachment}": :blob
        end
      end

      query
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
        flash[:notice] = t "avo.not_authorized"

        redirect_url = if request.referrer.blank? || (request.referrer == request.url)
          root_url
        else
          request.referrer
        end

        redirect_to(redirect_url)
      end
    end

    def set_authorization
      @authorization = Services::AuthorizationService.new _current_user
    end

    def set_container_classes
      contain = !Avo.configuration.full_width_container
      contain = false if Avo.configuration.full_width_index_view && action_name.to_sym == :index && self.class.superclass.to_s == "Avo::ResourcesController"

      @container_classes = contain ? "2xl:container 2xl:mx-auto" : ""
    end

    def add_initial_breadcrumbs
      instance_eval(&Avo.configuration.initial_breadcrumbs) if Avo.configuration.initial_breadcrumbs.present?
    end

    def on_root_path
      [Avo.configuration.root_path, "#{Avo.configuration.root_path}/"].include?(request.original_fullpath)
    end

    def on_resources_path
      request.original_url.match?(/.*\/#{Avo.configuration.namespace}\/resources\/.*/)
    end
  end
end
