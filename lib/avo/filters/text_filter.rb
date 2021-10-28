module Avo
  module Filters
    class TextFilter < BaseFilter
      class_attribute :button_label

      self.template = "avo/base/text_filter"
    end
  end
end
