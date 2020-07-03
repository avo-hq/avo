require_relative 'field'

module Avocado
  module Fields
    class BooleanField < Field
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'boolean-field',
          computable: true,
        }

        super(name, **args, &block)

        @true_value = args[:true_value].present? ? args[:true_value] : true
        @false_value = args[:false_value].present? ? args[:false_value] : false
      end

      def hydrate_field(fields, model, resource, view)
        {
          value: model[id] == @true_value,
          true_value: @true_value,
          false_value: @false_value,
        }
      end
    end
  end
end
