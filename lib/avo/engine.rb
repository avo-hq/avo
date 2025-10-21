# requires all dependencies
Gem.loaded_specs["avo"].dependencies.each do |d|
  case d.name
  when "activerecord"
    require "active_record/railtie"
  when "activesupport"
    require "active_support/railtie"
  when "actionview"
    require "action_view/railtie"
  when "activestorage"
    require "active_storage/engine"
  when "actiontext"
    require "action_text/engine"
  when "avo-heroicons"
    require "avo/heroicons"
  else
    require d.name
  end
end

module Avo
  class Engine < ::Rails::Engine
    isolate_namespace Avo

    config.after_initialize do
      # Reset before reloads in development
      ::Avo.asset_manager.reset

      # Boot Avo
      ::Avo.boot

      # After deploy we want to make sure the license response is being cleared.
      # We need a fresh license response.
      # This is disabled in development because the initialization process might be triggered more than once.
      if !Rails.env.development? && Avo.configuration.clear_license_response_on_deploy
        begin
          Licensing::HQ.new.clear_response
        rescue => exception
          Avo.logger.info "Failed to clear Avo HQ response: #{exception.message}"
        end
      end
    end

    # Ensure we reboot the app when something changes
    config.to_prepare do
      # Boot Avo
      ::Avo.boot
    end

    initializer "avo.autoload" do |app|
      # This undoes Rails' previous nested directories behavior in the `app` dir.
      # More on this: https://github.com/fxn/zeitwerk/issues/250
      avo_directory = Rails.root.join("app", "avo").to_s
      engine_avo_directory = Avo::Engine.root.join("app", "avo").to_s
      # Additional Avo namespaces managed outside app/avo
      host_controllers_dir = Rails.root.join("app", "controllers", "avo").to_s
      engine_controllers_dir = Avo::Engine.root.join("app", "controllers", "avo").to_s
      host_helpers_dir = Rails.root.join("app", "helpers", "avo").to_s
      engine_helpers_dir = Avo::Engine.root.join("app", "helpers", "avo").to_s
      host_components_dir = Rails.root.join("app", "components", "avo").to_s
      engine_components_dir = Avo::Engine.root.join("app", "components", "avo").to_s

      [
        avo_directory,
        engine_avo_directory,
        host_controllers_dir,
        engine_controllers_dir,
        host_helpers_dir,
        engine_helpers_dir,
        host_components_dir,
        engine_components_dir
      ].each do |directory_path|
        ActiveSupport::Dependencies.autoload_paths.delete(directory_path)
        Rails.autoloaders.main.do_not_eager_load(directory_path)
        Rails.autoloaders.main.ignore(directory_path)
      end

      # Load Avo app code (both host app and engine) with a dedicated Zeitwerk loader
      # that ignores global acronyms, so Avo constants camelize in the standard way
      # (e.g., `url_helpers` -> `UrlHelpers`).
      unless defined?(Avo::APP_AUTOLOADER)
        require_relative "ignore_acronyms_inflector"

        Avo::APP_AUTOLOADER = Zeitwerk::Loader.new
        Avo::APP_AUTOLOADER.tag = "avo-app"
        Avo::APP_AUTOLOADER.inflector = Avo::IgnoreAcronymsInflector.new
        Avo::APP_AUTOLOADER.enable_reloading if Rails.env.development?
      end

      [
        avo_directory,
        engine_avo_directory,
        host_controllers_dir,
        engine_controllers_dir,
        host_helpers_dir,
        engine_helpers_dir,
        host_components_dir,
        engine_components_dir
      ].each do |directory_path|
        next unless Dir.exist?(directory_path)
        Avo::APP_AUTOLOADER.push_dir(directory_path, namespace: Avo)
      end

      Avo::APP_AUTOLOADER.setup

      # Tie the Avo loader into Rails reloading lifecycle in development.
      if Rails.env.development?
        app.reloaders << Avo::APP_AUTOLOADER
        app.reloader.to_run { Avo::APP_AUTOLOADER.reload }
      end

      # Add the mount_avo method to Rails
      # rubocop:disable Style/ArgumentsForwarding
      ActionDispatch::Routing::Mapper.include(Module.new {
        def mount_avo(at: Avo.configuration.root_path, **options, &block)
          mount Avo::Engine, at:, **options

          scope at do
            Avo.plugin_manager.engines.each do |engine|
              mount engine[:klass], **engine[:options].dup
            end

            if block_given?
              Avo::Engine.routes.draw(&block)
            end
          end
        end
      })
      # rubocop:enable Style/ArgumentsForwarding
    end

    initializer "avo.reloader" do |app|
      Avo::Reloader.new.tap do |reloader|
        reloader.execute
        app.reloaders << reloader
        app.reloader.to_run { reloader.execute }
      end
    end

    initializer "avo.test_buddy" do |app|
      if Avo::IN_DEVELOPMENT
        Rails.autoloaders.main.push_dir Avo::Engine.root.join("spec", "testing_helpers")
      end
    end

    initializer "debug_exception_response_format" do |app|
      app.config.debug_exception_response_format = :api
    end

    config.app_middleware.use(
      Rack::Static,
      urls: ["/avo-assets"],
      root: Avo::Engine.root.join("public")
    )

    config.generators do |g|
      g.test_framework :rspec, view_specs: false
    end

    generators do |app|
      Rails::Generators.configure! app.config.generators
      require_relative "../generators/model_generator"
    end

    initializer "avo.locales" do |app|
      I18n.load_path += Dir[Avo::Engine.root.join("lib", "generators", "avo", "templates", "locales", "*.{rb,yml}")]
    end
  end
end
