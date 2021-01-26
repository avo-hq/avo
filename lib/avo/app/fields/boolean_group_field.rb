module Avo
  module Fields
    class BooleanGroupField < Field
      def initialize(name, **args, &block)
        @defaults = {
          component: 'boolean-group-field',
          computable: true,
        }

        super(name, **args, &block)

        @is_object_param = true

        @options = args[:options].present? ? args[:options] : nil
      end

      def options
        abort value.inspect
      end

      def hydrate_field(fields, model, resource, view)
        {
          options: @options,
        }
      end

      def fill_field(model, key, value)

        # return model unless value.is_a? ActionController::Parameters

        value = JSON.parse(value) if value.is_a? String

        # abort value.inspect

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
