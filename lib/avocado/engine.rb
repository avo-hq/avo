module Avocado
  class Engine < ::Rails::Engine
    isolate_namespace Avocado

    initializer 'avocado.init' do |app|
      avocado_root = Avocado::Engine.root.to_s
      puts 'avocado_root->'.inspect
      puts avocado_root.inspect
      # app.paths['app/views'].push File.join(avocado_root, 'src', 'tools')
      # puts paths.inspect

      if Rails.env == "development"
        puts 'avocado.init'.inspect

        # Register reloader
        app.reloaders << app.config.file_watcher.new([], {
          # Watch the src directory:
          Rails.root.join("avocado/src").to_s => ["rb"],
          # Rails.root.join("avocado/{src/app").to_s => ["rb"],
          # Rails.root.join("avocado/src/tools/**/").to_s => ["rb"],
        }) {}

        # What to do on file change
        config.to_prepare do
          puts 'to_prepare'.inspect
          Dir.glob(Rails.root + "avocado/src/**/*.rb").each { |c| load(c) }
        end
        # Dir.glob(Rails.root + "avocado/src/**/*.rb").each { |c| load(c) }
      end

      # Avocado::App.init
      # app.append_view_path Rails.root.join('src', 'tools')
      # paths["app/views"]           # => ["app/views"]
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
