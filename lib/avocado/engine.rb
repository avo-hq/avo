# requires all dependencies
Gem.loaded_specs['avocado'].dependencies.each do |d|
  require d.name
end

module Avocado
  class Engine < ::Rails::Engine
    isolate_namespace Avocado

    initializer 'avocado.init' do |app|
      avocado_root = Avocado::Engine.root.to_s

      if Rails.env == 'development'
        # Register reloader
        app.reloaders << app.config.file_watcher.new([], {
          Rails.root.join("avocado/lib/avocado").to_s => ["rb"],
        }) {}

        # What to do on file change
        config.to_prepare do
          Dir.glob(avocado_root + '/lib/avocado/app/**/*.rb'.to_s).each { |c| load(c) }
        end
      end
    end

    initializer "webpacker.proxy" do |app|
      insert_middleware = begin
                            Avocado.webpacker.config.dev_server.present?
                          rescue
                            nil
                          end
      next unless insert_middleware

      app.middleware.insert_before(
        0, Webpacker::DevServerProxy,
        ssl_verify_none: true,
        webpacker: Avocado.webpacker
      )
    end

    config.app_middleware.use(
      Rack::Static,
      urls: ["/avocado-packs"], root: Avocado::Engine.root.join("public")
    )
  end
end
