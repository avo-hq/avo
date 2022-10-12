module Avo
  module Fields
    class TimeField < DateField
      attr_reader :format
      attr_reader :picker_format
      attr_reader :time_24hr

      def initialize(id, **args, &block)
        super(id, **args, &block)

        add_boolean_prop args, :time_24hr
        add_string_prop args, :picker_format, "H:i:S"
        add_string_prop args, :format, "TT"
      end

      def formatted_value
        return nil if value.nil?

        value.to_time.iso8601
      end

      def edit_formatted_value
        return nil if value.nil?

        value.iso8601
      end
    end
  end
end
