
# frozen_string_literal: true

module Avo
  module Filters
    class DateTimeFilter < BaseFilter
      class_attribute :type, default: :date_time
      class_attribute :mode, default: :range

      self.template = 'avo/base/date_time_filter'

      def format
        case type
        when :date_time
          'yyyy-LL-dd TT'
        when :date
          'yyyy-LL-dd'
        end
      end

      def picker_format
        case type
        when :date_time
          'Y-m-d H:i:S'
        when :time
          'Y-m-d'
        end
      end
    end
  end
end
