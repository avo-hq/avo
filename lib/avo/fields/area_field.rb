# frozen_string_literal: true

module Avo
  module Fields
    class AreaField < BaseField
      class_attribute :supported_options, default: {}
      Avo::Fields::COMMON_OPTIONS.each do |common_option, hash|
        supports common_option, hash
      end

      supports :geometry, default: :polygon, possible_values: [:polygon, :multi_polygon]
      supports :mapkick_options, default: {}
      supports :datapoint_options, default: {}
      supports :demo, extra_info: "here"

      def initialize(id, **args, &block)
        hide_on :index

        super(id, **args, &block)
      end

      def map_data
        data_source = {
          geometry: {
            type: @geometry.to_s.classify,
            coordinates: value
          }
        }

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
