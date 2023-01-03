module Avo
  module Fields
    class TimeField < DateTimeField
      attr_reader :format
      attr_reader :picker_format

      def initialize(id, **args, &block)
        super(id, **args, &block)

        add_string_prop args, :picker_format, "H:i:S"
        add_string_prop args, :format, "TT"
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
    end
  end
end
