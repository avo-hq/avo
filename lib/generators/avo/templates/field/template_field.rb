module Avocado
  module Fields
    module <%= class_name %>
      class <%= class_name %>Field < Field
        def initialize(name, **args, &block)
          @defaults = {
            sortable: true,
            component: '<%= name %>-field',
            computable: true,
          }.merge(@defaults || {})

          super(name, **args, &block)
        end
      end
    end
  end
end
