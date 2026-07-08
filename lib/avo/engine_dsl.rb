require_relative "plugin_dsl"

module Avo
  module EngineDSL
    extend PluginDSL

    def self.extended(base)
      base.extend(PluginDSL)
    end

    def avo_engine(handler_class = nil)
      avo_plugin(handler_class, handler_name: "EngineHandler")
    end
  end
end
