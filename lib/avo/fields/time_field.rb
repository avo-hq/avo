module Avo
  module Fields
    class TimeField < DateTimeField

      class_attribute :supported_options, default: {}
      Avo::Fields::COMMON_OPTIONS.each do |common_option, hash|
        supports common_option, hash
      end

      supports :format, default: "TT"
      supports :picker_format, default: "H:i:S"

      def formatted_value
        return nil if value.nil?

        value.utc.to_time.iso8601
      end

      def edit_formatted_value
        return nil if value.nil?

        value.utc.iso8601
      end

      def fill_field(record, key, value, params)
        if value.in?(["", nil])
          record.send(:"#{id}=", value)

          return record
        end

        return record if value.blank?

        record.send(:"#{id}=", utc_time(value))

        record
      end
    end
  end
end
