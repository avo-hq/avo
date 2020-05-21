require_relative 'field'

module Avocado
  module Fields
    class NumberField < Field
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'number-field',
          computable: true,
        }

        super(name, **args, &block)

        @min = args[:min].present? ? args[:min].to_i : nil
        @max = args[:max].present? ? args[:max].to_i : nil
        @step = args[:step].present? ? args[:step].to_i : nil
      end

      def hydrate_resource(model, resource, view)
        {
          min: @min,
          max: @max,
          step: @step,
        }
      end
    end
  end
end
