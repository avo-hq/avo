require_relative 'field'

module Avocado
  module Fields
    class NumberField < Field
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'number-field',
        }

        super(name, **args, &block)

        @min = args[:min].present? ? args[:min].to_i : nil
        @max = args[:max].present? ? args[:max].to_i : nil
        @step = args[:step].present? ? args[:step].to_i : nil
      end

      def fetch_for_resource(model, resource, view)
        fields = super(model, resource, view)

        fields[:value] = @block.call model, resource, view, self if @block.present?

        fields[:min] = @min
        fields[:max] = @max
        fields[:step] = @step

        fields
      end
    end
  end
end
