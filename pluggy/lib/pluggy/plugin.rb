module Pluggy
  class Plugin < Avo::Plugin
    class << self
      def boot
        Avo.plugin_manager.register_field :radio, Pluggy::Fields::RadioField
      end

      def init
        Avo.plugin_manager.register_field :radio, Pluggy::Fields::RadioField
      end
    end
  end
end
