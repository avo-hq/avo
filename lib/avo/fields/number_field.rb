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
        @format_display_using = args[:format_display_using]
      end

      def value(property = nil)
        raw_value = super
        if @format_display_using && (view == :show || view == :index)
          return raw_value if @formatting
          @formatting = true
            formatted_value = instance_exec(&@format_display_using)
          @formatting = false
          return formatted_value
        elsif view == :edit
          raw_value
        end
      end 
    end
  end
end
