# requires all dependencies
Gem.loaded_specs["avo"].dependencies.each do |d|
  case d.name
  when "activerecord"
    require "active_record/railtie"
  when "actionview"
    require "action_view/railtie"
  when "activestorage"
    require "active_storage/engine"
  else
    require d.name
  end
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

    initializer "avo.autoload" do |app|
      Avo::ENTITIES.values.each do |path_params|
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

    initializer "avo.test_buddy" do |app|
      if Avo::IN_DEVELOPMENT
        Rails.autoloaders.main.push_dir Avo::Engine.root.join("spec", "helpers")
      end
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

    # After deploy we want to make sure the license response is being cleared.
    # We need a fresh license response.
    # This is disabled in development because the initialization process might be triggered more than once.
    config.after_initialize do
      unless Rails.env.development?
        begin
          Licensing::HQ.new.clear_response
        rescue => exception
          puts "Failed to clear Avo HQ response: #{exception.message}"
        end
      end
    end
  end
end
