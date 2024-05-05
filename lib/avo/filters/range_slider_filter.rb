module Avo
  module Filters
    class RangeSliderFilter < BaseFilter
      class_attribute :min, default: 1
      class_attribute :max, default: 100
      class_attribute :suffix, default: ''
      class_attribute :max_word, default: 'unlimited'
      class_attribute :uuid # required when displaying multi range sliders.

      self.template = "avo/base/range_slider_filter"
    end
  end
end
