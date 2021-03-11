# requires all dependencies
Gem.loaded_specs['avo'].dependencies.each do |d|
  require d.name
end
require 'view_component/engine'

module Avo
  class Engine < ::Rails::Engine
    isolate_namespace Avo

    initializer 'avo.autoload', before: :set_autoload_paths do |app|
      Rails.autoloaders.main.push_dir(Rails.root.join('app', 'avo', 'filters'))
      Rails.autoloaders.main.push_dir(Rails.root.join('app', 'avo', 'actions'))
      Rails.autoloaders.main.push_dir(Rails.root.join('app', 'avo', 'resources'))
    end

    initializer 'avo.init' do |app|
      avo_root_path = Avo::Engine.root.to_s

      app.config.middleware.use I18n::JS::Middleware

      if Avo::IN_DEVELOPMENT
        # Register reloader
        app.reloaders << app.config.file_watcher.new([], {
          Avo::Engine.root.join('lib', 'avo').to_s => ['rb'],
        }) {}

        # What to do on file change
        config.to_prepare do
          Dir.glob(avo_root_path + '/lib/avo/app/**/*.rb'.to_s).each { |c| load c }
          Avo::App.boot
        end
      else
        Dir.glob(avo_root_path + '/lib/avo/app/**/*.rb'.to_s).each { |c| require c }

        Avo::App.boot if Avo::PACKED
      end

      # if Rails.env.development?
      #   path_to_eager_load = 'app/avo/**/*.rb'

      #   config.eager_load_paths += Dir[path_to_eager_load]
      #   config.to_prepare do
      #     Dir[path_to_eager_load].each {|file| load file}
      #   end

      # end
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
