# frozen_string_literal: true

module Avo
  module Fields
    class AreaField < BaseField
      attr_reader :geometry
      attr_reader :style
      attr_reader :options
      def initialize(id, **args, &block)
        hide_on :index
        super(id, **args, &block)

        @geometry = args[:geometry].present? ? args[:geometry] : :polygon # Defaults to `polygon`; Possible values: `:polygon`, `:multi_polygon`
        @style = args[:style].present? ? args[:style] : nil
        @options = args[:options].present? ? args[:options] : {}
      end

      def map_data
        data = [{ geometry: { type: @geometry.to_s.classify, coordinates: JSON.parse(value) }}]

        if @options.present?
          [data[0].merge(@options)]
        else
          data
        end
      end

      def coordinates
        value.present? ? JSON.parse(value) : []
      end

      def geometry
        @geometry.to_s.classify
      end
    end
  end
end
