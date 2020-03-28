module Avocado
  class Engine < ::Rails::Engine
    isolate_namespace Avocado

    initializer 'avocado.init' do |app|
      if Rails.env == "development"
        puts 'avocado.init'.inspect

        # Register reloader
        app.reloaders << app.config.file_watcher.new([], {
          # Watch the src directory:
          Rails.root.join("avocado/src").to_s => ["rb"],
          }) {}

          # What to do on file change
          config.to_prepare do
            puts 'to_prepare'.inspect
            Dir.glob(Rails.root + "avocado/src/**/*.rb").each { |c| require(c) }
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
  end
end
