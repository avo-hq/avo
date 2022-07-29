module Avo
  module Fields
    class DateTimeField < DateField
      attr_reader :format
      attr_reader :picker_format
      attr_reader :time_24hr
      attr_reader :timezone

      def initialize(id, **args, &block)
        super(id, **args, &block)

        add_boolean_prop args, :time_24hr
        add_string_prop args, :picker_format, "Y-m-d H:i:S"
        add_string_prop args, :format, "yyyy-LL-dd TT"
        add_string_prop args, :timezone
      end

      def formatted_value
        return nil if value.nil?

        value.utc.to_time.iso8601
      end

      def edit_formatted_value
        return nil if value.nil?

        value.utc.iso8601
      end

      def fill_field(model, key, value, params)
        if value.in?(["", nil])
          model[id] = value

          return model
        end

        return model if value.blank?

        model[id] = utc_time(value)

        model
      end

      def utc_time(value)
        if timezone.present?
          ActiveSupport::TimeZone.new(timezone).local_to_utc(Time.parse(value))
        else
          value
        end
      end
    end
  end
end
