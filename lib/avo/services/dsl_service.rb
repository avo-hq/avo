module Avo
  module Services
    class DslService
      class << self
        def add_tool(container, klass, **args)
          container ||= []

          container << klass.new(**args)
        end

        # def add_field(container, instance)
        #   container ||= []

        #   container << instance
        # end
      end
    end
  end
end
