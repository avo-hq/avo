require "zeitwerk"
require "ostruct"
require "net/http"
require_relative "avo/version"
require_relative "avo/engine" if defined?(Rails)

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  "html" => "HTML",
  "uri_service" => "URIService",
  "has_html_attributes" => "HasHTMLAttributes"
)
loader.ignore("#{__dir__}/generators")
loader.setup

module Avo
  extend ActiveSupport::LazyLoadHooks

  ROOT_PATH = Pathname.new(File.join(__dir__, ".."))
  IN_DEVELOPMENT = ENV["AVO_IN_DEVELOPMENT"] == "1"
  PACKED = !IN_DEVELOPMENT
  COOKIES_KEY = "avo"
  ACTIONS_TURBO_FRAME_ID = :actions_show
  ACTIONS_BACKGROUND_FRAME = :actions_background

  class LicenseVerificationTemperedError < StandardError; end

  class LicenseInvalidError < StandardError; end

  class NotAuthorizedError < StandardError; end

  class NoPolicyError < StandardError; end

  class MissingGemError < StandardError; end

  class DeprecatedAPIError < StandardError; end

  class MissingResourceError < StandardError
    def initialize(resource_name)
      super(missing_resource_message(resource_name))
    end

    private

    def missing_resource_message(resource_name)
      name = resource_name.to_s.underscore

      "Failed to find a resource while rendering the :#{name} field.\n" \
      "You may generate a resource for it by running 'rails generate avo:resource #{name.singularize}'.\n" \
      "\n" \
      "Alternatively add the 'use_resource' option to the :#{name} field to specify a custom resource to be used.\n" \
      "More info on https://docs.avohq.io/#{Avo::VERSION[0]}.0/resources.html."
    end
  end

  class << self
    attr_reader :logger
    attr_reader :cache_store
    attr_reader :field_manager

    delegate :license, :app, :error_manager, :tool_manager, :resource_manager, to: Avo::Current

    # Runs when the app boots up
    def boot
      @logger = Avo.configuration.logger
      @field_manager = Avo::Fields::FieldManager.build
      @cache_store = Avo.configuration.cache_store
      plugin_manager.boot_plugins
      Avo.run_load_hooks(:boot, self)
      eager_load_actions
    end

    # Runs on each request
    def init
      Avo::Current.error_manager = Avo::ErrorManager.build
      # Check rails version issues only on NON Production environments
      check_rails_version_issues unless Rails.env.production?
      Avo::Current.resource_manager = Avo::Resources::ResourceManager.build
      Avo::Current.tool_manager = Avo::Tools::ToolManager.build

      Avo.run_load_hooks(:init, self)
    end

    # Generate a dynamic root path using the URIService
    def root_path(paths: [], query: {}, **args)
      Avo::Services::URIService.parse(Avo::Current.view_context.avo.root_url.to_s)
        .append_paths(paths)
        .append_query(query)
        .to_s
    end

    def main_menu
      return unless Avo.plugin_manager.installed?("avo-menu")

      # Return empty menu if the app doesn't have the profile menu configured
      return Avo::Menu::Builder.new.build unless has_main_menu?

      Avo::Menu::Builder.parse_menu(&Avo.configuration.main_menu)
    end

    def profile_menu
      return unless Avo.plugin_manager.installed?("avo-menu")

      # Return empty menu if the app doesn't have the profile menu configured
      return Avo::Menu::Builder.new.build unless has_profile_menu?

      Avo::Menu::Builder.parse_menu(&Avo.configuration.profile_menu)
    end

    def app_status
      license.valid?
    end

    def avo_dynamic_filters_installed?
      defined?(Avo::DynamicFilters).present?
    end

    def has_main_menu?
      return false if Avo.license.lacks_with_trial(:menu_editor)
      return false if Avo.configuration.main_menu.nil?

      true
    end

    def has_profile_menu?
      return false if Avo.license.lacks_with_trial(:menu_editor)
      return false if Avo.configuration.profile_menu.nil?

      true
    end

    # Mount all Avo engines
    def mount_engines
      -> {
        mount Avo::DynamicFilters::Engine, at: "/avo-dynamic_filters" if defined?(Avo::DynamicFilters::Engine)
        mount Avo::Dashboards::Engine, at: "/dashboards" if defined?(Avo::Dashboards::Engine)
        mount Avo::Pro::Engine, at: "/avo-pro" if defined?(Avo::Pro::Engine)
      }
    end

    def extra_gems
      [:pro, :advanced, :menu, :dynamic_filters, :dashboards, :enterprise, :audits]
    end

    def eager_load_actions
      Rails.autoloaders.main.eager_load_namespace(Avo::Actions) if defined?(Avo::Actions)
    end

    def check_rails_version_issues
      if Rails.version.start_with?("7.1") && Avo.configuration.license.in?(["pro", "advanced"])
        Avo.error_manager.add({
          url: "https://docs.avohq.io/3.0/upgrade.html#upgrade-from-3-7-4-to-3-9-1",
          target: "_blank",
          message: "Due to a Rails 7.1 bug the following features won't work:\n\r
                    - Dashboards\n\r
                    - Ordering\n\r
                    - Dynamic filters\n\r
                    We recommend you upgrade to Rails 7.2\n\r
                    Click banner for more information."
        })
      end
    end
  end
end

loader.eager_load
