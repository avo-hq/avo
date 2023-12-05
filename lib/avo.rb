require "zeitwerk"
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

  class LicenseVerificationTemperedError < StandardError; end

  class LicenseInvalidError < StandardError; end

  class NotAuthorizedError < StandardError; end

  class NoPolicyError < StandardError; end

  class MissingGemError < StandardError; end

  class DeprecatedAPIError < StandardError; end

  class << self
    attr_reader :logger
    attr_reader :cache_store
    attr_reader :field_manager

    delegate :license, :app, :error_manager, :tool_manager, :resource_manager, to: Avo::Current

    def boot
      @logger = Avo.configuration.logger
      @field_manager = Avo::Fields::FieldManager.build
      @cache_store = Avo.configuration.cache_store
      plugin_manager.boot_plugins
      Avo.run_load_hooks(:boot, self)
    end

    def init
      Avo::Current.error_manager = Avo::ErrorManager.build
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

    def mount_path
      Avo::Engine.routes.find_script_name({})
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
  end
end

loader.eager_load
