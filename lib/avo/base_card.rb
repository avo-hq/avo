module Avo
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
    attr_accessor :options
    attr_accessor :index
    attr_accessor :params

    delegate :context, to: ::Avo::App

    class << self
      def query(&block)
        self.query_block = block
      end
    end

    def initialize(dashboard:, options: {}, index: 0, cols: nil, rows: nil, label: nil, description: nil, refresh_every: nil)
      @dashboard = dashboard
      @options = options
      @index = index
      @cols = cols
      @rows = rows
      @label = label
      @refresh_every = refresh_every
      @description = description
    end

    def label
      return @label.to_s if @label.present?
      return self.class.label.to_s if self.class.label.present?

      self.class.id.to_s.humanize
    end

    def description
      @description || self.class.description
    end

    def refresh_every
      @refresh_every || self.class.refresh_every
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

    def frame_url(enforced_range: nil, params: {})
      enforced_range ||= initial_range || ranges.first

      # append the parent params to the card request
      begin
        other_params = "&#{params.permit!.to_h.map { |k, v| "#{k}=#{v}" }.join("&")}"
      rescue
      end

      "#{Avo::App.root_path}/dashboards/#{dashboard.id}/cards/#{id}?turbo_frame=#{turbo_frame}&index=#{index}&range=#{enforced_range}#{other_params}"
    end

    def card_classes
      result = ""

      result += case cols.to_i
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

      result += case rows.to_i
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
      Avo::Hosts::DashboardCard.new(card: self, dashboard: dashboard, params: params, context: context, range: range, options: options)
        .compute_result

      self
    end

    def hydrate(dashboard: nil, params: nil)
      @dashboard = dashboard if dashboard.present?
      @params = params if params.present?

      self
    end

    def range
      return params[:range] if params.dig(:range).present?

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

    private

    def cols
      @cols || self.class.cols
    end

    def rows
      @rows || self.class.rows
    end
  end
end
