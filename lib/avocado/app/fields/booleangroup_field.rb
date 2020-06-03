require_relative 'field'

module Avocado
  module Fields
    class BooleangroupField < Field
      def initialize(name, **args, &block)
        @defaults = {
          # sortable: true,
          component: 'booleangroup-field',
          computable: true,
        }

        super(name, **args, &block)

        @is_object_param = true

        # @true_value = args[:true_value].present? ? args[:true_value] : true
        # @false_value = args[:false_value].present? ? args[:false_value] : false
        @options = args[:options].present? ? args[:options] : {}
        @no_value_text = args[:no_value_text].present? ? args[:no_value_text] : '-'
        @hide_false_values = args[:hide_false_values].present? ? args[:hide_false_values] : false
        @hide_true_values = args[:hide_true_values].present? ? args[:hide_true_values] : false
      end

      def hydrate_resource(model, resource, view)
        {
          # true_value: @true_value,
          # false_value: @false_value,
          options: @options,
          no_value_text: @no_value_text,
          hide_false_values: @hide_false_values,
          hide_true_values: @hide_true_values,
        }
      end

      def fill_model(model, value)
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
