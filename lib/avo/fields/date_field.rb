module Avo
  module Fields
    class DateField < TextField
      attr_reader :first_day_of_week
      attr_reader :picker_format
      attr_reader :disable_mobile
      attr_reader :format
      attr_reader :relative

      def initialize(id, **args, &block)
        super(id, **args, &block)

        add_string_prop args, :first_day_of_week, 0
        add_string_prop args, :picker_format, "Y-m-d"
        add_string_prop args, :format, "yyyy-LL-dd"
        add_boolean_prop args, :relative
        add_boolean_prop args, :disable_mobile
      end

      def formatted_value
        return if value.blank?

        value.iso8601
      end

      def edit_formatted_value
        return nil if value.nil?

        value.iso8601
      end
    end
  end
end
