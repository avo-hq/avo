module Avo
  module Fields
    class BooleanField < BaseField
      attr_reader :true_value
      attr_reader :false_value

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @true_value = args[:true_value].present? ? args[:true_value] : true
        @false_value = args[:false_value].present? ? args[:false_value] : false
      end

      def value
        resolve_attribute super
      end

      def resolve_attribute(value)
        value.present? ? value.in?(truthy_values) : value
      end

      def truthy_values
        ["true", "1", @true_value]
      end

      def falsy_values
        ["false", "0", @false_value]
      end
    end
  end
end
