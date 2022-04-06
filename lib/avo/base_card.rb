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

    attr_accessor :parent
    attr_accessor :options
    attr_accessor :index
    attr_accessor :params

    delegate :context, to: ::Avo::App

    class << self
      def query(&block)
        self.query_block = block
      end
    end

    def initialize(parent:, options: {}, index: 0, cols: nil, rows: nil, label: nil, description: nil, refresh_every: nil)
      @parent = parent
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
      # puts ["parent->", parent, dashboard, parent_is_dashboard?].inspect
      # abort resource.inspect
      if parent_is_dashboard?
        "#{dashboard.id}_#{id}"
      elsif parent_is_resource?
        "#{resource.id}_#{resource.model.id}_#{id}"
      end
    end

    def frame_url(enforced_range: nil, params: {})
      enforced_range ||= initial_range || ranges.first

      # append the parent params to the card request
      begin
        other_params = "&#{params.permit!.to_h.map { |k, v| "#{k}=#{v}" }.join("&")}"
      rescue
      end
      # puts ["parent_is_dashboard?->", parent_is_dashboard?, parent.superclass, parent.class.superclass].inspect

      if parent_is_dashboard?
        "#{Avo::App.root_path}/dashboards/#{dashboard.id}/cards/#{id}?turbo_frame=#{turbo_frame}&index=#{index}&range=#{enforced_range}#{other_params}"
      elsif parent_is_resource?
        "#{Avo::App.root_path}/resources/#{resource.route_key}/#{resource.model.id}/cards/#{id}?turbo_frame=#{turbo_frame}&index=#{index}&range=#{enforced_range}#{other_params}"
      end
    end

    def card_classes
      result = ""

      # Writing down the classes so TailwindCSS knows not to purge them
      classes_for_cols = {
        1 => " sm:col-span-1",
        2 => " sm:col-span-2",
        3 => " sm:col-span-3",
        4 => " sm:col-span-4",
        5 => " sm:col-span-5",
        6 => " sm:col-span-6"
      }

      classes_for_rows = {
        1 => " h-36",
        2 => " h-72",
        3 => " h-[27rem]",
        4 => " h-[36rem]",
        5 => " h-[45rem]",
        6 => " h-[54rem]"
      }
      # puts ["cols->", cols, classes_for_cols, classes_for_rows, classes_for_cols[cols.to_i]].inspect

      result += classes_for_cols[cols.to_i] if classes_for_cols[cols.to_i].present?
      result += classes_for_rows[rows.to_i] if classes_for_rows[rows.to_i].present?

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

    def hydrate(parent: nil, params: nil)
      @parent = parent if parent.present?
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

    def parent_is_dashboard?
      parent.superclass == Avo::Dashboards::BaseDashboard

      # args[:resource] = self if
      # args[:dashboard] = self if superclass == Avo::Dashboards::BaseDashboard
      # dashboard.present?
    end

    def parent_is_resource?
      # resource.present?
      parent.superclass == Avo::BaseResource
    end

    def resource
      parent if parent_is_resource?
    end

    def dashboard
      parent if parent_is_dashboard?
    end
  end
end
