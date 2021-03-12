# requires all dependencies
Gem.loaded_specs['avo'].dependencies.each do |d|
  require d.name
end
require 'view_component/engine'

module Avo
  class Engine < ::Rails::Engine
    isolate_namespace Avo

    # Add the lib directory to autoloaders
    config.autoload_paths << File.expand_path("../", __dir__)

    config.after_initialize do
      # Load all the fields so we can register their definitions
      Dir[Rails.root.join('app', 'avo', 'resources', '*.rb')].each {|file| require file }
      # Boot Avo
      ::Avo::App.boot
    end

    initializer 'avo.autoload', before: :set_autoload_paths do |app|
      Rails.autoloaders.main.push_dir(Rails.root.join('app', 'avo', 'filters'))
      Rails.autoloaders.main.push_dir(Rails.root.join('app', 'avo', 'actions'))
      Rails.autoloaders.main.push_dir(Rails.root.join('app', 'avo', 'resources'))
    end

    initializer 'avo.init_fields' do |app|
      # Init the fields
      ::Avo::App.init_fields
    end

    initializer 'webpacker.proxy' do |app|
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
      urls: ['/avo-packs'],
      root: Avo::Engine.root.join('public')
    )

    config.generators do |g|
      g.test_framework :rspec, view_specs: false
    end
  end
end
