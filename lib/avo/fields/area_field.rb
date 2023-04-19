# frozen_string_literal: true

module Avo
  module Fields
    class AreaField < BaseField
      attr_reader :geometry
      def initialize(id, **args, &block)
        hide_on :index
        super(id, **args, &block)

        # Defaults to `polygon`; Possible values: `Polygon`, `multi_polygon`
        @geometry = args[:geometry].present? ? args[:geometry] : 'polygon'
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
