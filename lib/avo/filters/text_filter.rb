module Avo
  module Filters
    class TextFilter < BaseFilter
      class_attribute :button_label

      self.template = "avo/base/text_filter"

      def selected_value(applied_filters)
        default_value
      end
    end
  end
end
