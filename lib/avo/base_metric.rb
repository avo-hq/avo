module Avo
  class BaseMetric
    class_attribute :label
    class_attribute :cols
    class_attribute :range
    class_attribute :ranges

    class << self
      def parsed_ranges
        return unless ranges.present?

        ranges.map do |range|
          if range.kind_of? Integer
            ["#{range} days", range.to_s]
          else
            [range, range.to_s]
          end
        end
      end
    end
  end
end
