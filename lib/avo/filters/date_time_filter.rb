# frozen_string_literal: true

module Avo
  module Filters
    class DateTimeFilter < BaseFilter
      class_attribute :type, default: :date_time
      class_attribute :mode, default: :range

      self.template = "avo/base/date_time_filter"

      def picker_format
        case type
        when :date
          "Y-m-d"
        when :date_time
          "Y-m-d H:i:S"
        when :time
          "H:i:S"
        end
      end

      def picker_options(value)
        {
          defaultDate: value,
          enableTime: has_time?,
          enableSeconds: has_time?,
          time_24hr: has_time? ? true : nil,
          noCalendar: type == :time,
          mode: mode,
          dateFormat: picker_format,
          minuteIncrement: has_time? ? 1 : nil
        }.compact
      end

      def has_time?
        @has_time ||= type.in?([:time, :date_time])
      end
    end
  end
end
