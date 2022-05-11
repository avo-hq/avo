# requires all dependencies
Gem.loaded_specs["avo"].dependencies.each do |d|
  require d.name
end

# In development we should load the engine so we get the autoload for components
if ENV["RAILS_ENV"] === "development"
  require "view_component/engine"
end

module Avo
  class Engine < ::Rails::Engine
    isolate_namespace Avo

    config.after_initialize do
      # Boot Avo
      ::Avo::App.boot
    end

    config.i18n.load_path += Dir[Avo::Engine.root.join("lib", "generators", "avo", "templates", "locales", "*.{rb,yml}")]

    initializer "avo.autoload" do |app|
      [
        ["app", "avo", "fields"],
        ["app", "avo", "filters"],
        ["app", "avo", "actions"],
        ["app", "avo", "resources"],
        ["app", "avo", "dashboards"],
        ["app", "avo", "cards"]
      ].each do |path_params|
        path = Rails.root.join(*path_params)

        if File.directory? path.to_s
          Rails.autoloaders.main.push_dir path.to_s
        end
      end
    end

    initializer "avo.init_fields" do |app|
      # Init the fields
      ::Avo::App.init_fields
    end

    initializer "avo.reloader" do |app|
      Avo::Reloader.new.tap do |reloader|
        reloader.execute
        app.reloaders << reloader
        app.reloader.to_run { reloader.execute }
      end
    end

    initializer "debug_exception_response_format" do |app|
      app.config.debug_exception_response_format = :api
      # app.config.logger = ::Logger.new(STDOUT)
    end

    config.app_middleware.use(
      Rack::Static,
      urls: ["/avo-assets"],
      root: Avo::Engine.root.join("public")
    )

    config.generators do |g|
      g.test_framework :rspec, view_specs: false
    end

    # After deploy we want to make sure the license response is being cleared.
    # We need a fresh license response.
    # This is disabled in development because the initialization process might be triggered more than once.
    config.after_initialize do
      unless Rails.env.development?
        begin
          Licensing::HQ.new.clear_response
        rescue => exception
          puts "Failed to clear Avo HQ response: #{e.message}"
        end
      end
    end
  end
end
