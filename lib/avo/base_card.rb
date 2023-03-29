module Avo
  class BaseCard
    include Avo::Concerns::VisibleInDashboard

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
    attr_accessor :arguments
    attr_accessor :index
    attr_accessor :params

    delegate :context, to: ::Avo::App
    delegate :current_user, to: ::Avo::App
    delegate :view_context, to: ::Avo::App
    delegate :params, to: ::Avo::App
    delegate :request, to: ::Avo::App

    class << self
      def query(&block)
        self.query_block = block
      end
    end

    def initialize(dashboard:, options: {}, arguments: {}, index: 0, cols: nil, rows: nil, label: nil, description: nil, refresh_every: nil, visible: nil)
      @dashboard = dashboard
      @options = options
      @arguments = arguments
      @index = index
      @cols = cols
      @rows = rows
      @label = label
      @refresh_every = refresh_every
      @description = description
      @visible = visible
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

    def turbo_frame
      "#{dashboard.id}_#{id}"
    end

    def frame_url(enforced_range: nil, params: {})
      enforced_range ||= initial_range || ranges.first

      Avo::App.view_context.avo.dashboard_card_path(dashboard.id, id, turbo_frame: turbo_frame, index: index, range: enforced_range, **params.permit!)
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

      result += classes_for_cols[cols.to_i] if classes_for_cols[cols.to_i].present?
      result += classes_for_rows[rows.to_i] if classes_for_rows[rows.to_i].present?

      result
    end

    def type
      return :metric if is_a?(::Avo::Dashboards::MetricCard)
      return :chartkick if is_a?(::Avo::Dashboards::ChartkickCard)
      return :partial if is_a?(::Avo::Dashboards::PartialCard)
    end

    def compute_result
      Avo::Hosts::DashboardCard.new(card: self, dashboard: dashboard, params: params, context: context, range: range, options: options)
        .compute_result

      self
    end

    def hydrate(dashboard: nil)
      @dashboard = dashboard if dashboard.present?

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

    def visible
      @visible || self.class.visible
    end

    def call_block
      ::Avo::Hosts::CardVisibility.new(block: visible, card: self, parent: dashboard).handle
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
