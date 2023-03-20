module Avo
  module Fields
    class DateField < TextField
      attr_reader :first_day_of_week
      attr_reader :picker_format
      attr_reader :disable_mobile
      attr_reader :format
      attr_reader :picker_options

      def initialize(id, **args, &block)
        super(id, **args, &block)

        add_string_prop args, :first_day_of_week, 1
        add_string_prop args, :picker_format, "Y-m-d"
        add_string_prop args, :format, "yyyy-LL-dd"
        add_boolean_prop args, :disable_mobile
        add_object_prop args, :picker_options
      end

      def formatted_value
        return if value.blank?

        try_iso8601
      end

      def edit_formatted_value
        return nil if value.nil?

        try_iso8601
      end

      private

      def try_iso8601
        if value.is_a?(String)
          parsed = DateTime.parse(value)
          value = parsed
        end

        value.iso8601
      end
    end
  end
end
