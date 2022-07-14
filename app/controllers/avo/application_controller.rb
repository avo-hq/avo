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
    before_action :init_app
    before_action :check_avo_license
    before_action :set_default_locale
    around_action :set_force_locale, if: -> { params[:force_locale].present? }
    before_action :set_authorization
    before_action :_authenticate!
    before_action :set_container_classes
    before_action :add_initial_breadcrumbs
    before_action :set_view

    rescue_from Pundit::NotAuthorizedError, with: :render_unauthorized
    rescue_from ActiveRecord::RecordInvalid, with: :exception_logger

    helper_method :_current_user,
      :resources_path,
      :resource_path,
      :new_resource_path,
      :edit_resource_path,
      :resource_detach_path,
      :related_resources_path,
      :turbo_frame_request?
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

    def set_view
      @view = action_name.to_sym
    end

    def in_association?
      params[:associated_resource_class].present?
    end

    # Figure out the resource segment key from the URL
    # /admin/resources/super/duper/projects/3/wonka/donka/comments/395 we should get `super/duper/projects`
    def segment_from_class_name
      self.class.name.delete_prefix("Avo::").delete_suffix("Controller").gsub("::", "/").downcase
    end

    def resource_segment
      if in_association?
        resource_regex = /.*resources\/(\D*)\/?\d*\/#{segment_from_class_name}/
        request.path.match(resource_regex)[1].delete_suffix "/"
      else
        segment_from_class_name
      end
    end

    def association_id_param
      :"#{model_param_key}_id"
    end

    # Gets the Avo resource for this request based on the request from the `resource_name` "param"
    # Ex: Avo::Resources::Project, Avo::Resources::Team, Avo::Resources::User
    def resource
      Avo::App.get_resource_by_resource_segment resource_segment
      # abort in_association?.inspect
      # abort params.inspect

      # controller_based_resource = Avo::App.get_resource_by_controller_class(self.class)
      # abort self.class.inspect
      # # abort controller_based_resource.inspect

      # return controller_based_resource if controller_based_resource.present?

      # resource = App.get_resource @resource_name.to_s.camelize.singularize

      # return resource if resource.present?

      # App.guess_resource @resource_name
    end

    def set_resource
      raise ActionController::RoutingError.new "No route matches!" if resource.nil?

      @resource = resource.hydrate(params: params, view: action_name.to_sym, user: _current_user)
    end

    def related_resource
      return Avo::App.get_resource_by_controller_class(self.class)
      return App.get_resource params[:associated_resource_class] if params[:associated_resource_class].present?

      reflection = @model._reflections[related_resource_name]

      reflected_model = reflection.klass

      App.get_resource_by_model_name reflected_model
    end

    def set_related_resource
      # abort 'set_related_resource->'.inspect
      @related_resource = related_resource.hydrate(params: params)
    end

    # On associations, the model is the one calling the association.
    # For this path, the model is Project.find 3
    # /admin/resources/super/duper/projects/3/wonka/donka/comments/395
    def set_model
      # abort @resource.inspect
      if in_association?
        # abort action_name.inspect
        @model = eager_load_files(@resource, @resource.class.find_scope).find params[association_id_param]
      else
        @model = eager_load_files(@resource, @resource.class.find_scope).find params[:id]
      end
    end

    # The related model is the associated one.
    # /avo/resources/posts/4?turbo_frame=has_one_field_show_post&resource_class=UserResource&associated_record_=39
    # For this path, the related model is Post.find 4
    def set_related_model
      @related_model = eager_load_files(@related_resource, @model.send(params[:field_id])).find params[:id]
    end

    def set_reflection
      @reflection = @model._reflections[params[:field_id]]
    end

    def set_attachment_class
      @attachment_class = @reflection.klass
    end

    def set_attachment_model
      @attachment_model = @attachment_class.find attachment_id
    end

    def set_attachment_resource
      @attachment_resource = App.get_resource_by_model_name @attachment_class
    end


    # ------------------

    # def set_resource_name
    #   @resource_name = resource_name
    # end

    # def set_related_resource_name
    #   @related_resource_name = related_resource_name
    # end

    def set_model_to_fill
      @model_to_fill = @resource.model_class.new if @view == :create
      @model_to_fill = @model if @view == :update
    end

    def fill_model
      # We have to skip filling the the model if this is an attach action
      is_attach_action = params[model_param_key].blank? && related_resource_name.present? && params[:fields].present?

      unless is_attach_action
        @model = @resource.fill_model(@model_to_fill, cast_nullable(model_params))
      end
    end

    def hydrate_related_resource
      @related_resource.hydrate(view: action_name.to_sym, user: _current_user)
    end

    def authorize_action
      if @model.present?
        @authorization.set_record(@model).authorize_action action_name.to_sym
      else
        @authorization.set_record(@resource.model_class).authorize_action action_name.to_sym
      end
    end

    # Get the pluralized resource name for this request
    # Ex: projects, teams, users
    # def resource_name
    #   possible_resource_class = params[:resource_name] || params[:resource_class]


    #   return App.get_resource possible_resource_class if possible_resource_class.present?

    #   controller_based_resource = Avo::App.get_resource_by_controller_class(self.class)

    #   return controller_based_resource.route_key if controller_based_resource.present?

    #   return request.path_info.split('/').select(&:present?).second if self.class != Avo::AssociationsController

    #   return controller_name if controller_name.present?

    #   begin
    #     request.path.match(/\/?#{Avo::App.root_path.delete('/')}\/resources\/([a-z1-9\-_]*)\/?/mi).captures.first
    #   rescue
    #   end

    #   request.path_info.split('/').select(&:present?).second
    # end

    # def related_resource_name
    #   # params[:related_name]
    #   # abort request.path_info.inspect
    #   # puts ["request.path->", request.path].inspect
    #   # params[:related_name] || params[:field_id]
    #   # params[:field_id] || request.path_info.split('/').select(&:present?).second
    #   # abort ["associated_resource_class->", params[:associated_resource_class]].inspect
    #   possible_resource_class = params[:associated_resource_class]

    #   return App.get_resource possible_resource_class if possible_resource_class.present?

    #   params[:associated_resource_class]
    # end

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

    def set_default_locale
      I18n.locale = params[:set_locale] || I18n.default_locale

      I18n.default_locale = I18n.locale
    end

    # Temporary set the locale and reverting at the end of the request.
    def set_force_locale
      initial_locale = I18n.locale.to_s.dup
      I18n.locale = params[:force_locale]
      yield
      I18n.locale = initial_locale
    end

    def default_url_options
      if params[:force_locale].present?
        { **super, force_locale: params[:force_locale] }
      else
        super
      end
    end
  end
end
