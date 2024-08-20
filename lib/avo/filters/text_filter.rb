module Avo
  module Filters
    class TextFilter < BaseFilter
      self.template = "avo/base/text_filter"

      def selected_value(applied_filters)
        applied_or_default_value
      end
    end
  end
end
