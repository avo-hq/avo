module Avo
  module HarborTheme
    class Engine < ::Rails::Engine
      isolate_namespace Avo::HarborTheme

      initializer "avo-harbor_theme.assets" do |app|
        if app.config.respond_to?(:assets) && defined?(Sprockets)
          app.config.assets.precompile += %w[avo-harbor_theme_manifest.js]
        end
      end
    end
  end
end
