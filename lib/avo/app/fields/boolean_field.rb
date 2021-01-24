module Avo
  module Fields
    class BooleanField < Field
      def initialize(name, **args, &block)
        @defaults = {
          partial_name: 'boolean-field',
          computable: true,
        }

        super(name, **args, &block)

        @true_value = args[:true_value].present? ? args[:true_value] : true
        @false_value = args[:false_value].present? ? args[:false_value] : false
      end

      def hydrate_field(fields, model, resource, view)
        {
          value: resolve_attribute(fields[:value]),
          true_value: @true_value,
          false_value: @false_value,
        }
      end

      def resolve_attribute(value)
        value.present? ? value.in?(truthy_values) : value
      end

      def truthy_values
        ['true', '1', @true_value]
      end

      def falsy_values
        ['false', '0', @false_value]
      end
    end
  end
end
