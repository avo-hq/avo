module Avo
  module Fields
    class NumberField < TextField
      attr_reader :min
      attr_reader :max
      attr_reader :step

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @min = args[:min].present? ? args[:min].to_f : nil
        @max = args[:max].present? ? args[:max].to_f : nil
        @step = args[:step].present? ? args[:step].to_f : nil
      end
    end
  end
end
