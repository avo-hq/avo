module Avo
  module Filters
    class RangeSliderFilter < BaseFilter
      class_attribute :min, default: 1
      class_attribute :max, default: 120
      class_attribute :suffix, default: 'min'
      class_attribute :max_word, default: 'unlimited'

      self.template = "avo/base/range_slider_filter"
    end
  end
end
