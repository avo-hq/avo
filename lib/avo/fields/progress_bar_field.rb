module Avo
  module Fields
    class ProgressBarField < BaseField
      attr_reader :max
      attr_reader :step
      attr_reader :display_value
      attr_reader :value_suffix

      def initialize(name, **args, &block)
        super(name, **args, &block)

        @max = args[:max] || 100
        @step = args[:step] || 1
        @display_value = args[:display_value] || false
        @value_suffix = args[:value_suffix] || nil
      end
    end
  end
end
