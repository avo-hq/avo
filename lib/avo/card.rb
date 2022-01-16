module Avo
  class Card
    attr_reader :id
    attr_reader :block
    attr_reader :partial
    attr_reader :description
    attr_reader :prefix
    attr_reader :suffix
    attr_reader :metric
    attr_reader :range
    attr_reader :dashboard

    def initialize(
      id: '',
      label: nil,
      cols: 1,
      block: nil,
      partial: nil,
      description: nil,
      prefix: nil,
      suffix: nil,
      metric: nil,
      range: nil,
      ranges: [],
      dashboard: nil
    )
      @id = id
      @label = label
      @cols = cols
      @block = block
      @partial = partial
      @description = description
      @prefix = prefix
      @suffix = suffix
      @metric = metric
      @range = range
      @ranges = ranges
      @dashboard = dashboard
    end

    def label
      @label || @id.to_s.humanize
    end

    def turbo_frame
      "#{dashboard.id}_#{id}"
    end

    def frame_url(range: nil)
      range ||= @range || @ranges.first
      "#{Avo::App.root_path}/dashboards/#{dashboard.id}/cards/#{id}?turbo_frame=#{turbo_frame}&range=#{range}"
    end

    def card_classes
      case @cols.to_i
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
      return :metric if metric.class == Class && metric.superclass == Avo::BaseMetric

      :string
    end

    def value(dashboard:, range:)
      if type == :metric
        metric.new.value context: Avo::App.context,
                    dashboard: dashboard,
                    card: self,
                    range: range
      else
        metric
      end
    end
  end
end
