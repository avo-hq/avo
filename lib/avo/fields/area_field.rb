# frozen_string_literal: true

module Avo
  module Fields
    class AreaField < BaseField
      attr_reader :geometry
      attr_reader :options
      attr_reader :datapoint_options
      def initialize(id, **args, &block)
        hide_on :index
        super(id, **args, &block)

        @geometry = args[:geometry].presence || :polygon # Defaults to `polygon`; Possible values: `:polygon`, `:multi_polygon`
        @options = args[:options].present? ? args[:options] : {}
        @datapoint_options = args[:datapoint_options].present? ? args[:datapoint_options] : {}
      end

      def map_data
        data_source = { geometry: { type: @geometry.to_s.classify, coordinates: JSON.parse(value) }}
        [data_source.merge(datapoint_options)]
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
