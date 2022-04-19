module Avo
  module Filters
    class MultipleSelectFilter < BaseFilter
      self.template = "avo/base/multiple_select_filter"

      # The input expects an array of strings for the value
      def selected_value(applied_filters)
        return default_value(applied_filters).keys if default_value(applied_filters).present?

        []
      end
    end
  end
end
