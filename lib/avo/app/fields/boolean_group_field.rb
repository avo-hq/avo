module Avo
  module Fields
    class BooleanGroupField < Field
      attr_reader :options

      def initialize(name, **args, &block)
        @defaults = {
          partial_name: 'boolean-group-field',
          computable: true,
        }

        super(name, **args, &block)

        @options = args[:options].present? ? args[:options] : {}
      end

      def to_permitted_param
        [:"#{id}", "#{id}": {} ]
      end

      def fill_field(model, key, value)
        return model unless value.is_a? ActionController::Parameters

        new_value = {}

        value.each do |key, value|
          new_value[key] = ActiveModel::Type::Boolean.new.cast value
        end

        model[id] = new_value

        model
      end
    end
  end
end
