module Pluggy
  class Railtie < Rails::Railtie
    initializer "pluggy.init" do
      Avo.plugin_manager.register Pluggy::Plugin
    end
  end
end
