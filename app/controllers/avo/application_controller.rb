module Avo
  class ApplicationController < ::ActionController::Base
    if defined?(Pundit::Authorization)
      include Pundit::Authorization
    else
      include Pundit
    end

    include Pagy::Backend
    include Avo::ApplicationHelper
    include Avo::UrlHelpers

    protect_from_forgery with: :exception
    around_action :set_avo_locale
    around_action :set_force_locale, if: -> { params[:force_locale].present? }
    before_action :set_default_locale, if: -> { params[:set_locale].present? }
    before_action :init_app
    before_action :check_avo_license
    before_action :set_authorization
    before_action :_authenticate!
    before_action :set_container_classes
    before_action :add_initial_breadcrumbs
    before_action :set_view
    before_action :set_sidebar_open

    rescue_from Pundit::NotAuthorizedError, with: :render_unauthorized
    rescue_from ActiveRecord::RecordInvalid, with: :exception_logger

    helper_method :_current_user, :resources_path, :resource_path, :new_resource_path, :edit_resource_path, :resource_attach_path, :resource_detach_path, :related_resources_path, :turbo_frame_request?
    add_flash_types :info, :warning, :success, :error

    def init_app
      Avo::App.init request: request, context: context, current_user: _current_user, view_context: view_context, params: params

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

      if params[:controller] == "avo/search" && params[:action] == "index"
        raise Avo::LicenseVerificationTemperedError, "License verification mechanism tempered with." unless method(:index).source_location.first.match?(/.*\/app\/controllers\/avo\/search_controller\.rb/)
      end

      if params[:controller] == "avo/dashboards" && params[:action] == "show"
        raise Avo::LicenseVerificationTemperedError, "License verification mechanism tempered with." unless method(:show).source_location.first.match?(/.*\/app\/controllers\/avo\/dashboards_controller\.rb/)
      end

      if params[:controller] == "avo/dashboards" && params[:action] == "card"
        raise Avo::LicenseVerificationTemperedError, "License verification mechanism tempered with." unless method(:card).source_location.first.match?(/.*\/app\/controllers\/avo\/dashboards_controller\.rb/)
      end

      super(*args)
    end

    def check_avo_license
      # Check to see if the path is a custom tool
      if on_custom_tool_page
        if @license.lacks(:custom_tools) || @license.invalid?
          message = "Your license is invalid or doesn't support custom tools."
        end
      end

      # Check to see if the path is a dashboard
      if on_dashboards_path
        if @license.lacks(:dashboards) || @license.invalid?
          message = "Your license is invalid or doesn't support dashboards."
        end
      end

      if message.present?
        if Rails.env.development? || Rails.env.test?
          @custom_tools_alert_visible = message
        elsif @license.lacks_with_trial(:custom_tools)
          # Raise error in non-development environments.
          raise Avo::LicenseInvalidError, message
        end
      end
    end

    def _current_user
      instance_eval(&Avo.configuration.current_user)
    end

    def context
      instance_eval(&Avo.configuration.context)
    end

    # This is coming from Turbo::Frames::FrameRequest module.
    # Exposing it as public method
    def turbo_frame_request?
      super
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
      @model = eager_load_files(@resource, @resource.class.find_scope).find params[:id]
    end

    def set_related_model
      @related_model = if @field.is_a? Avo::Fields::HasOneField
        @model.send params[:related_name]
      else
        eager_load_files(@related_resource, @model.send(params[:related_name])).find params[:related_id]
      end
    end

    def set_view
      @view = action_name.to_sym
    end

    def set_model_to_fill
      @model_to_fill = @resource.model_class.new if @view == :create
      @model_to_fill = @model if @view == :update
    end

    def fill_model
      # We have to skip filling the the model if this is an attach action
      is_attach_action = params[model_param_key].blank? && params[:related_name].present? && params[:fields].present?

      unless is_attach_action
        @model = @resource.fill_model(@model_to_fill, cast_nullable(model_params))
      end
    end

    def hydrate_resource
      @resource.hydrate(view: action_name.to_sym, user: _current_user)
    end

    def hydrate_related_resource
      @related_resource.hydrate(view: action_name.to_sym, user: _current_user, model: @model)
    end

    def authorize_base_action
      class_to_authorize = @model || @resource.model_class

      authorize_action class_to_authorize
    end

    def authorize_action(class_to_authorize, action = nil)
      # Use the provided action or figure it out from the request
      action_to_authorize = action || action_name

      @authorization.set_record(class_to_authorize).authorize_action action_to_authorize.to_sym
    end

    # Get the pluralized resource name for this request
    # Ex: projects, teams, users
    def resource_name
      return params[:resource_name] if params[:resource_name].present?

      return controller_name if controller_name.present?

      begin
        request.path
          .match(/\/?#{Avo::App.root_path.delete('/')}\/resources\/([a-z1-9\-_]*)\/?/mi)
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

          return query.includes "#{field.id}_#{attachment}": :blob
        end
      end

      query
    end

    def _authenticate!
      instance_eval(&Avo.configuration.authenticate)
    end

    def render_unauthorized(exception)
      if !exception.is_a? Pundit::NotDefinedError
        flash.now[:notice] = t "avo.not_authorized"

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
      contain = true

      if Avo.configuration.full_width_container
        contain = false
      elsif Avo.configuration.full_width_index_view && action_name.to_sym == :index && self.class.superclass.to_s == "Avo::ResourcesController"
        contain = false
      end

      @container_classes = contain ? "2xl:container 2xl:mx-auto" : ""
    end

    def add_initial_breadcrumbs
      instance_eval(&Avo.configuration.initial_breadcrumbs) if Avo.configuration.initial_breadcrumbs.present?
    end

    def on_root_path
      [Avo.configuration.root_path, "#{Avo.configuration.root_path}/"].include?(request.original_fullpath)
    end

    def on_resources_path
      request.original_url.match?(/.*#{Avo.configuration.root_path}\/resources\/.*/)
    end

    def on_api_path
      request.original_url.match?(/.*#{Avo.configuration.root_path}\/avo_api\/.*/)
    end

    def on_dashboards_path
      request.original_url.match?(/.*#{Avo.configuration.root_path}\/dashboards\/.*/)
    end

    def on_debug_path
      request.original_url.match?(/.*#{Avo.configuration.root_path}\/avo_private\/debug.*/)
    end

    def on_custom_tool_page
      !(on_root_path || on_resources_path || on_api_path || on_dashboards_path || on_debug_path)
    end

    def model_param_key
      @resource.form_scope
    end

    # Sets the locale set in avo.rb initializer
    def set_avo_locale(&action)
      locale = Avo.configuration.locale || I18n.default_locale
      I18n.with_locale(locale, &action)
    end

    # Enable the user to change the default locale with the `?set_locale=pt-BR` param
    def set_default_locale
      locale = params[:set_locale] || I18n.default_locale

      I18n.default_locale = locale
    end

    # Temporary set the locale and reverting at the end of the request.
    def set_force_locale(&action)
      locale = params[:force_locale] || I18n.default_locale
      I18n.with_locale(locale, &action)
    end

    def default_url_options
      if params[:force_locale].present?
        {**super, force_locale: params[:force_locale]}
      else
        super
      end
    end

    def set_sidebar_open
      value = cookies["#{Avo::COOKIES_KEY}.sidebar.open"]
      @sidebar_open = value.blank? || value == "1"
    end
  end
end
