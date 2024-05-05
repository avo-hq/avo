module Avo
  module Filters
    class RangeSliderFilter < BaseFilter
      class_attribute :min, default: 1
      class_attribute :max, default: 100
      class_attribute :suffix, default: ''
      class_attribute :max_word, default: 'unlimited'
      class_attribute :uniq_slider_id # If multiple range sliders are used, a unique id must be specified.

      self.template = "avo/base/range_slider_filter"
    end
  end
end
