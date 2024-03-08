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
      unless Rails.env.development?
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
      ActiveSupport::Dependencies.autoload_paths.delete(avo_directory)

      if Dir.exist?(avo_directory)
        Rails.autoloaders.main.push_dir(avo_directory, namespace: Avo)
        app.config.watchable_dirs[avo_directory] = [:rb]
      end
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
