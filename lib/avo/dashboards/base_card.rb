module Avo
  module Dashboards
    class BaseCard
      attr_reader :dashboard

      class_attribute :id
      class_attribute :label
      class_attribute :description
      class_attribute :cols, default: 1
      class_attribute :rows, default: 1
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
        return "#{range} days" if range.is_a? Integer

        case range
        when "MTD"
          "Month to date"
        when "QTD"
          "Quarter to date"
        when "YTD"
          "Year to date"
        when "TODAY"
          "Today"
        else
          range
        end
      end

      def parsed_ranges
        return unless ranges.present?

        ranges.map { |range| [translated_range(range), range] }
      end

      def turbo_frame
        "#{dashboard.id}_#{id}"
      end

      def frame_url(enforced_range: nil)
        enforced_range ||= range || ranges.first
        "#{Avo::App.root_path}/dashboards/#{dashboard.id}/cards/#{id}?turbo_frame=#{turbo_frame}&range=#{enforced_range}"
      end

      def card_classes
        result = ""

        result += case self.class.cols.to_i
        when 1
          " col-span-1"
        when 2
          " col-span-2"
        when 3
          " col-span-3"
        when 4
          " col-span-4"
        when 5
          " col-span-5"
        when 6
          " col-span-6"
        else
          " col-span-1"
        end

        result += case self.class.rows.to_i
        when 1
          " h-36"
        when 2
          " h-72"
        when 3
          " h-[27rem]"
        when 4
          " h-[36rem]"
        when 5
          " h-[45rem]"
        when 6
          " h-[54rem]"
        end

        result
      end

      def type
        return :metric if self.class.superclass == ::Avo::Dashboards::MetricCard
        return :chartkick if self.class.superclass == ::Avo::Dashboards::ChartkickCard
        return :partial if self.class.superclass == ::Avo::Dashboards::PartialCard
      end
    end
  end
end
