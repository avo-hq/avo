# frozen_string_literal: true

module Avo
  module Filters
    class DateTimeFilter < BaseFilter
      class_attribute :with_time, default: false
      class_attribute :date_field

      self.template = "avo/base/date_time_filter"

      def apply(request, query, params)
        raise "Define the class attribute date_field in #{self.class}" if date_field.nil?

        start_date = params["start"].presence
        end_date = params["end"].presence

        query.where(Hash[date_field, start_date..end_date])
      end

      def format
        with_time ? "yyyy-LL-dd TT" : "yyyy-LL-dd"
      end

      def picker_format
        with_time ? "Y-m-d H:i:S" : "Y-m-d"
      end
    end
  end
end
