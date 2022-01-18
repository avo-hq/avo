module Avo
  module Dashboards
    class BaseCard
      attr_reader :dashboard

      class_attribute :id
      class_attribute :label
      class_attribute :description
      class_attribute :cols
      class_attribute :range
      class_attribute :ranges, default: []
      class_attribute :refresh_every

      def initialize(dashboard:)
        @dashboard = dashboard
      end

      def label
        return self.class.label.to_s if self.class.label.to_s.present?

        self.class.id.to_s.humanize
      end

      def translated_range(range)
        return "#{range} days" if range.kind_of? Integer

        case range
        when 'MTD'
          'Month to date'
        when 'QTD'
          'Quarter to date'
        when 'YTD'
          'Year to date'
        when 'TODAY'
          'Today'
        else
          range
        end
      end

      def parsed_ranges
        return unless ranges.present?

        ranges.map { |range| [translated_range(range), range] }
      end
    end
  end
end
