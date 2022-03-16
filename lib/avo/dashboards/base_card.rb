module Avo
  module Dashboards
    class BaseCard
      class_attribute :id
      class_attribute :label
      class_attribute :description
      class_attribute :cols, default: 1
      class_attribute :rows, default: 1
      class_attribute :initial_range
      class_attribute :ranges, default: []
      class_attribute :refresh_every
      class_attribute :display_header, default: true
      # private
      class_attribute :result_data
      class_attribute :query_block

      attr_accessor :dashboard
      attr_accessor :params

      delegate :context, to: ::Avo::App

      class << self
        def query(&block)
          self.query_block = block
        end
      end

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
        enforced_range ||= initial_range || ranges.first
        "#{Avo::App.root_path}/dashboards/#{dashboard.id}/cards/#{id}?turbo_frame=#{turbo_frame}&range=#{enforced_range}"
      end

      def card_classes
        result = ""

        result += case self.class.cols.to_i
        when 1
          " sm:col-span-1"
        when 2
          " sm:col-span-2"
        when 3
          " sm:col-span-3"
        when 4
          " sm:col-span-4"
        when 5
          " sm:col-span-5"
        when 6
          " sm:col-span-6"
        else
          " sm:col-span-1"
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

      def compute_result
        Avo::Hosts::DashboardCard.new(card: self, dashboard: dashboard, params: params, context: context, range: range)
          .compute_result

        self
      end

      def hydrate(dashboard: nil, params: nil)
        @dashboard = dashboard if dashboard.present?
        @params = params if params.present?

        self
      end

      def range
        return params[:range] if params.present? && params[:range].present?

        return initial_range if initial_range.present?

        ranges.first
      end

      def result(data)
        self.result_data = data

        self
      end

      def is_card?
        true
      end

      def is_divider?
        false
      end
    end
  end
end
