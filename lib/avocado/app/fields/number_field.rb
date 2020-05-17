require_relative './field'

module Avocado
  module Fields
    class NumberField < Field
      def initialize(name, **args, &block)
        super(name, **args, &block)

        @component = 'number-field'
        @sortable = true


        @min = args[:min].present? ? args[:min].to_i : nil
        @max = args[:max].present? ? args[:max].to_i : nil
        @step = args[:step].present? ? args[:step].to_i : nil
      end
    end

    def fetch_for_resource(model, view = :index)
      fields = super(model, view)

      abort self.inspect if id == 'age'
      fields[:value] = @block.call model, self if @block.present?

      fields[:min] = @min
      fields[:max] = @max
      fields[:step] = @step

      fields
    end
  end
end
