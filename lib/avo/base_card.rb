module Avo
  class BaseCard
    attr_reader :id
    attr_reader :dashboard

    class_attribute :label
    class_attribute :description
    class_attribute :cols
    class_attribute :range
    class_attribute :ranges, default: []
    class_attribute :refresh_every

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

    def initialize(id:, dashboard:, card: )
      @id = id
      @dashboard = dashboard
    end
  end
end
