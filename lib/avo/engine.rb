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

    config.i18n.load_path += Dir[Avo::Engine.root.join('lib', 'generators', 'avo', 'templates', 'locales', '*.{rb,yml}')]

    initializer "avo.autoload", before: :set_autoload_paths do |app|
      [
        ["app", "avo", "fields"],
        ["app", "avo", "filters"],
        ["app", "avo", "actions"],
        ["app", "avo", "resources"]
      ].each do |path_params|
        path = Rails.root.join(*path_params)

        if File.directory? path.to_s
          Rails.autoloaders.main.push_dir path
        end
      end
    end

    initializer "avo.init_fields" do |app|
      # Init the fields
      ::Avo::App.init_fields
    end

    initializer "avo.reload_avo_files" do |app|
      if Avo::IN_DEVELOPMENT && ENV["RELOAD_AVO_FILES"]
        avo_root_path = Avo::Engine.root.to_s
        # Register reloader
        app.reloaders << app.config.file_watcher.new([], {
          Avo::Engine.root.join("lib", "avo").to_s => ["rb"]
        }) {}

        # What to do on file change
        config.to_prepare do
          Dir.glob(avo_root_path + "/lib/avo/**/*.rb".to_s).each { |c| load c }
          Avo::App.boot
        end
      end
    end

    initializer "webpacker.proxy" do |app|
      app.config.debug_exception_response_format = :api
      # app.config.logger = ::Logger.new(STDOUT)

      insert_middleware = begin
        Avo.webpacker.config.dev_server.present?
      rescue
        nil
      end

      if insert_middleware
        app.middleware.insert_before(
          0, Webpacker::DevServerProxy,
          ssl_verify_none: true,
          webpacker: Avo.webpacker
        )
      end
    end

    config.app_middleware.use(
      Rack::Static,
      urls: ["/avo-packs"],
      root: Avo::Engine.root.join("public")
    )

    config.generators do |g|
      g.test_framework :rspec, view_specs: false
    end
  end
end
