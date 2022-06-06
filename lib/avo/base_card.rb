module Avo
  class BaseCard
    include Avo::Concerns::StylesCards
    include Avo::Fields::FieldExtensions::VisibleInDifferentViews

    class_attribute :id
    class_attribute :label
    class_attribute :description
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

    def initialize(parent:, options: {}, index: 0, cols: nil, rows: nil, label: nil, description: nil, refresh_every: nil, **args)
      @parent = parent
      @options = options
      @index = index
      @cols = cols
      @rows = rows
      @label = label
      @refresh_every = refresh_every
      @description = description

      initialize_visibility args
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
      if parent_is_dashboard?
        "#{parent.id}_#{id}"
      elsif parent_is_resource?
        "#{parent.id}_#{parent.model.id}_#{id}"
      end
    end

    def frame_url(enforced_range: nil, params: {})
      enforced_range ||= initial_range || ranges.first

      # append the parent params to the card request
      begin
        other_params = "&#{params.permit!.to_h.map { |k, v| "#{k}=#{v}" }.join("&")}"
      rescue
      end

      if parent_is_dashboard?
        "#{Avo::App.root_path}/dashboards/#{dashboard.id}/cards/#{id}?turbo_frame=#{turbo_frame}&index=#{index}&range=#{enforced_range}#{other_params}"
      elsif parent_is_resource?
        "#{Avo::App.root_path}/resources/#{parent.route_key}/#{parent.model.id}/cards/#{id}?turbo_frame=#{turbo_frame}&index=#{index}&range=#{enforced_range}#{other_params}"
      end
    end

    def type
      return :metric if self.class.superclass == ::Avo::Dashboards::MetricCard
      return :chartkick if self.class.superclass == ::Avo::Dashboards::ChartkickCard
      return :partial if self.class.superclass == ::Avo::Dashboards::PartialCard
    end

    def compute_result
      Avo::Hosts::DashboardCard.new(card: self, parent: parent, params: params, context: context, range: range, options: options)
        .compute_result

      self
    end

    def hydrate(parent: nil, params: nil, view: nil)
      @parent = parent if parent.present?
      @params = params if params.present?
      @view = view if view.present?

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

    def parent_is_dashboard?
      parent.class.superclass == Avo::Dashboards::BaseDashboard
    end

    def parent_is_resource?
      parent.class.superclass == Avo::BaseResource
    end

    def resource
      parent if parent_is_resource?
    end

    def dashboard
      parent if parent_is_dashboard?
    end
  end
end
