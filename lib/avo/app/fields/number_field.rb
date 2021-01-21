require_relative 'text_field'

module Avo
  module Fields
    class NumberField < TextField
      def initialize(name, **args, &block)
        @defaults = {
          component: 'number-field',
          computable: true,
        }

        super(name, **args, &block)

        @min = args[:min].present? ? args[:min].to_f : nil
        @max = args[:max].present? ? args[:max].to_f : nil
        @step = args[:step].present? ? args[:step].to_f : nil
      end

      def hydrate_field(fields, model, resource, view)
        {
          min: @min,
          max: @max,
          step: @step,
        }
      end
    end
  end
end
