module Avo
  module PluginDSL
    def avo_plugin(handler_class, handler_name:)
      handler_class ||= "#{name.deconstantize}::#{handler_name}".constantize
      instance_exec(&handler_class.handle)
    end
  end
end
