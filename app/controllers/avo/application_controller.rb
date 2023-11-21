module Avo
  class ApplicationController < ::ActionController::Base
    if defined?(Pundit::Authorization)
      Avo::ApplicationController.include Pundit::Authorization
    elsif defined?(Pundit)
      Avo::ApplicationController.include Pundit
    end

    include Avo::InitializesAvo
    include Avo::ApplicationHelper
    include Avo::UrlHelpers
    include Avo::Concerns::Breadcrumbs

    protect_from_forgery with: :exception
    around_action :set_avo_locale
    around_action :set_force_locale, if: -> { params[:force_locale].present? }
    before_action :set_default_locale, if: -> { params[:set_locale].present? }
    before_action :init_app
    before_action :set_active_storage_current_host
    before_action :set_resource_name
    before_action :_authenticate!
    before_action :set_authorization
    before_action :set_container_classes
    before_action :add_initial_breadcrumbs
    before_action :set_view
    before_action :set_sidebar_open
    before_action :set_stylesheet_assets_path

    rescue_from Avo::NotAuthorizedError, with: :render_unauthorized
    rescue_from ActiveRecord::RecordInvalid, with: :exception_logger

    helper_method :_current_user, :resources_path, :resource_path, :new_resource_path, :edit_resource_path, :resource_attach_path, :resource_detach_path, :related_resources_path, :turbo_frame_request?, :resource_view_path, :preview_resource_path
    add_flash_types :info, :warning, :success, :error

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

    # Get the pluralized resource name for this request
    # Ex: projects, teams, users
    def resource_name
      return params[:resource_name] if params[:resource_name].present?

      return controller_name if controller_name.present?

      begin
        request.path
          .match(/\/?#{Avo.root_path.delete('/')}\/resources\/([a-z1-9\-_]*)\/?/mi)
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
      resource = Avo.resource_manager.get_resource @resource_name.to_s.camelize.singularize

      return resource if resource.present?

      Avo.resource_manager.get_resource_by_controller_name @resource_name
    end

    def related_resource
      # Find the field from the parent resource
      field = @resource.get_field params[:related_name]

      return field.use_resource if field&.use_resource.present?

      reflection = @record._reflections[params[:related_name]]

      reflected_model = reflection.klass

      Avo.resource_manager.get_resource_by_model_class reflected_model
    end

    def set_resource_name
      @resource_name = resource_name
    end

    def set_related_resource_name
      @related_resource_name = related_resource_name
    end

    def set_resource
      raise ActionController::RoutingError.new "No route matches" if resource.nil?

      @resource = resource.new(view: params[:view] || action_name.to_s, user: _current_user, params: params)

      set_authorization
    end

    def detect_fields
      @resource.detect_fields
    end

    def set_related_resource
      @related_resource = related_resource.new(params: params, view: action_name.to_sym, user: _current_user, record: @related_record).detect_fields
    end

    def set_record
      @record = @resource.find_record(params[:id], query: model_scope, params: params)
      @resource.hydrate(record: @record)
    end

    def set_related_record
      association_name = BaseResource.valid_association_name(@record, params[:related_name])
      @related_record = if @field.is_a? Avo::Fields::HasOneField
        @record.send association_name
      else
        @related_resource.find_record params[:related_id], query: @record.send(association_name), params: params
      end
      @related_resource.hydrate(record: @related_record)
    end

    def model_scope
      # abort @resource.inspect
      @resource.class.find_scope
    end

    def set_view
      @view = Avo::ViewInquirer.new(action_name.to_s)
    end

    def set_record_to_fill
      @record_to_fill = @resource.model_class.new if @view.create?
      @record_to_fill = @record if @view.update?

      # If resource.record is nil, most likely the user is creating a new record.
      # In that case, to access resource.record in visible and readonly blocks we hydrate the resource with a new record.
      # TODO: commented this
      @resource.hydrate(record: @record_to_fill) if @resource.record.nil?
    end

    def fill_record
      # We have to skip filling the the record if this is an attach action
      return if is_attach_action?

      @record = @resource.fill_record(@record_to_fill, cast_nullable(model_params), extra_params: extra_params)
      assign_default_value_to_disabled_fields if @view.create?
    end

    def is_attach_action?
      params[model_param_key].blank? && params[:related_name].present? && params[:fields].present?
    end

    def assign_default_value_to_disabled_fields
      @resource.get_field_definitions.select do |field|
        field.is_disabled? && field.visible? && !field.computed
      end.each do |field|
        # Get the default value from the field default definition
        # If there is no default value specified on the resource, get the value from the record (DB, Callbacks, etc.)
        default_value = field.default || @record.send(field.id)
        field.fill_field @record, field.id, default_value, params
      end
    end

    def authorize_base_action
      class_to_authorize = @record || @resource.model_class

      authorize_action class_to_authorize
    end

    def authorize_action(class_to_authorize, action = nil)
      # Use the provided action or figure it out from the request
      action_to_authorize = action || action_name

      @authorization.set_record(class_to_authorize).authorize_action action_to_authorize.to_sym
    end

    def _authenticate!
      instance_eval(&Avo.configuration.authenticate)
    end

    def render_unauthorized(exception)
      flash[:notice] = t "avo.not_authorized"

      redirect_url = if request.referrer.blank? || (request.referrer == request.url)
        root_url
      else
        request.referrer
      end

      redirect_to(redirect_url)
    end

    def set_authorization
      # We need to set @resource_name for the #resource method to work properly
      set_resource_name
      @authorization = if @resource
        @resource.authorization(user: _current_user)
      else
        Services::AuthorizationService.new _current_user
      end
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

    # Set the current host for ActiveStorage
    def set_active_storage_current_host
      if defined?(ActiveStorage::Current)
        if Rails::VERSION::MAJOR === 6
          ActiveStorage::Current.host = request.base_url
        elsif Rails::VERSION::MAJOR === 7
          ActiveStorage::Current.url_options = {protocol: request.protocol, host: request.host, port: request.port}
        end
      end
    rescue => exception
      Avo.logger.debug "Failed to set ActiveStorage::Current.url_options, #{exception.inspect}"
    end

    def set_stylesheet_assets_path
      # Prefer the user's tailwind config if it exists, otherwise use the default one from Avo
      @stylesheet_assets_path = if Rails.root.join("config", "avo", "tailwind.config.js").exist?
        "avo.tailwind"
      elsif Avo::PACKED
        "/avo-assets/avo.base"
      else
        "avo.base"
      end
    end
  end
end
