module Avo
  module EngineDSL
    def avo_engine(handler_class = nil)
      handler_class ||= "#{name.deconstantize}::EngineHandler".constantize
      instance_exec(&handler_class.handle)
    end
  end
end
