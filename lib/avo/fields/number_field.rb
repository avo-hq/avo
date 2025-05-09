module Avo
  module Fields
    class NumberField < TextField
      include ActionView::Helpers::NumberHelper
      attr_reader :min
      attr_reader :max
      attr_reader :step
      attr_reader :format_display_using

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @min = args[:min].present? ? args[:min].to_f : nil
        @max = args[:max].present? ? args[:max].to_f : nil
        @step = args[:step].present? ? args[:step].to_f : nil
      end
    end
  end
end
