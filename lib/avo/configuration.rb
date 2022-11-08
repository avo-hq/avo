module Avo
  class Configuration
    include ResourceConfiguration

    attr_writer :root_path
    attr_accessor :app_name
    attr_accessor :timezone
    attr_accessor :per_page
    attr_accessor :per_page_steps
    attr_accessor :via_per_page
    attr_accessor :locale
    attr_accessor :currency
    attr_accessor :default_view_type
    attr_accessor :license
    attr_accessor :license_key
    attr_accessor :authorization_methods
    attr_accessor :authenticate
    attr_accessor :current_user
    attr_accessor :id_links_to_resource
    attr_accessor :full_width_container
    attr_accessor :full_width_index_view
    attr_accessor :cache_resources_on_index_view
    attr_accessor :cache_resource_filters
    attr_accessor :context
    attr_accessor :display_breadcrumbs
    attr_accessor :hide_layout_when_printing
    attr_accessor :initial_breadcrumbs
    attr_accessor :home_path
    attr_accessor :search_debounce
    attr_accessor :view_component_path
    attr_accessor :display_license_request_timeout_error
    attr_accessor :current_user_resource_name
    attr_accessor :raise_error_on_missing_policy
    attr_accessor :disabled_features
    attr_accessor :buttons_on_form_footers
    attr_accessor :main_menu
    attr_accessor :profile_menu
    attr_accessor :model_resource_mapping
    attr_accessor :tabs_style
    attr_accessor :resource_default_view
    attr_accessor :authorization_client
    attr_accessor :field_wrapper_layout
    attr_accessor :sign_out_path_name
    attr_writer :branding

    def initialize
      @root_path = "/avo"
      @app_name = ::Rails.application.class.to_s.split("::").first.underscore.humanize(keep_id_suffix: true)
      @timezone = "UTC"
      @per_page = 24
      @per_page_steps = [12, 24, 48, 72]
      @via_per_page = 8
      @locale = nil
      @currency = "USD"
      @default_view_type = :table
      @license = "community"
      @license_key = nil
      @current_user = proc {}
      @authenticate = proc {}
      @authorization_methods = {
        index: "index?",
        show: "show?",
        edit: "edit?",
        new: "new?",
        update: "update?",
        create: "create?",
        destroy: "destroy?"
      }
      @id_links_to_resource = false
      @full_width_container = false
      @full_width_index_view = false
      @cache_resources_on_index_view = Avo::PACKED
      @cache_resource_filters = false
      @context = proc {}
      @initial_breadcrumbs = proc {
        add_breadcrumb I18n.t("avo.home").humanize, avo.root_path
      }
      @display_breadcrumbs = true
      @hide_layout_when_printing = false
      @home_path = nil
      @search_debounce = 300
      @view_component_path = "app/components"
      @display_license_request_timeout_error = true
      @current_user_resource_name = "user"
      @raise_error_on_missing_policy = false
      @disabled_features = []
      @buttons_on_form_footers = false
      @main_menu = nil
      @profile_menu = nil
      @model_resource_mapping = {}
      @tabs_style = :tabs
      @resource_default_view = :show
      @authorization_client = :pundit
      @field_wrapper_layout = :inline
    end

    def current_user_method(&block)
      @current_user = block if block.present?
    end

    def current_user_method=(method)
      @current_user = method if method.present?
    end

    def authenticate_with(&block)
      @authenticate = block if block.present?
    end

    def set_context(&block)
      @context = block if block.present?
    end

    def set_initial_breadcrumbs(&block)
      @initial_breadcrumbs = block if block.present?
    end

    def namespace
      if computed_root_path.present?
        computed_root_path.delete "/"
      else
        root_path.delete "/"
      end
    end

    def root_path
      return "" if @root_path === "/"

      @root_path
    end

    def computed_root_path
      Avo.configuration.root_path
    end

    def feature_enabled?(feature)
      !@disabled_features.map(&:to_sym).include?(feature.to_sym)
    end

    def branding
      Avo::Configuration::Branding.new(**@branding || {})
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configuration=(config)
    @configuration = config
  end

  def self.configure
    yield configuration
  end
end
