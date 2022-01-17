module Avo
  class Card
    attr_reader :id
    attr_reader :partial
    attr_reader :metric
    attr_reader :chartkick
    # keep for partial card
    # attr_reader :cols
    # attr_reader :description
    attr_reader :dashboard
    # attr_reader :refresh_every
    attr_reader :instance

    def initialize(
      id: '',
      label: nil,
      cols: 1,
      block: nil,
      partial: nil,
      # description: nil,
      metric: nil,
      chartkick: nil,
      dashboard: nil,
      # chart_type: nil,
      # query: -> {  },
      refresh_every: nil
      # chart_options: {},
      # omit_position_offset: false
    )
      @id = id
      @label = label
      @cols = cols
      @block = block
      @partial = partial
      # @description = description
      @metric = metric
      @chartkick = chartkick

      @dashboard = dashboard
      # @chart_type = chart_type
      # @query = query
      @refresh_every = refresh_every
      # @chart_options = chart_options
      # @omit_position_offset = omit_position_offset
      if @metric.present?
        @instance = metric.new id: @id, dashboard: @dashboard, card: @card
      elsif @chartkick.present?
        @instance = chartkick.new id: @id, dashboard: @dashboard, card: @card
      elsif @partial.present?
        @instance = partial.new id: @id, dashboard: @dashboard, card: @card
      else
        # @instance = self
      end
    end

    def turbo_frame
      "#{dashboard.id}_#{id}"
    end

    def frame_url(enforced_range: nil)
      enforced_range ||= range || ranges.first
      "#{Avo::App.root_path}/dashboards/#{dashboard.id}/cards/#{id}?turbo_frame=#{turbo_frame}&range=#{enforced_range}"
    end

    def card_classes
      case cols.to_i
      when 1
        'col-span-1'
      when 2
        'col-span-2'
      when 3
        'col-span-3'
      when 4
        'col-span-4'
      when 5
        'col-span-5'
      when 6
        'col-span-6'
      else
        'col-span-1'
      end
    end

    def type
      return :metric if metric.class == Class
      return :chartkick if chartkick.class == Class

      :string
    end

    # def value(dashboard:, range:)
    #   if type == :metric
    #     metric.new.value context: Avo::App.context,
    #                      dashboard: dashboard,
    #                      card: self,
    #                      range: range
    #   elsif type == :chatkick
    #     # send(@card.chart_type, @card.query.call(context: context, range: @range, dashboard: @dashboard, card: @card), **@card.chartkick_options)
    #     metric.new.query context: Avo::App.context,
    #                      dashboard: dashboard,
    #                      card: self,
    #                      range: range
    #   else
    #     metric
    #   end
    # end

    def label
      return metric.label if type == :metric && metric.label.present?

      @label || @id.to_s.humanize
    end

    # @todo: pass these trhough
    def description
      instance.description
    end

    def cols
      instance.cols
    end

    def range
      instance.range
    end

    def ranges
      instance.ranges
    end

    def refresh_every
      instance.refresh_every
    end
  end
end
