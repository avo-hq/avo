# frozen_string_literal: true

module Avo
  module Filters
    class DateTimeFilter < BaseFilter
      class_attribute :type, default: :date_time
      class_attribute :mode, default: :range

      self.template = "avo/base/date_time_filter"

      def picker_format
        case type
        when :date_time
          "Y-m-d H:i:S"
        when :time
          "H:i:S"
        end
      end
    end
  end
end
