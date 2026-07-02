require_relative "plugin_dsl"

module Avo
  module RailtieDSL
    extend PluginDSL

    def self.extended(base)
      base.extend(PluginDSL)
    end

    def avo_railtie(handler_class = nil)
      avo_plugin(handler_class, handler_name: "RailtieHandler")
    end
  end
end
