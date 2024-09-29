module Pluggy
  class Railtie < Rails::Railtie
    initializer "pluggy.init" do
      ActiveSupport.on_load(:avo_boot) do
        Avo.plugin_manager.register :pluggy

        Avo.plugin_manager.register_field :radio, Pluggy::Fields::RadioField
      end
    end
  end
end
