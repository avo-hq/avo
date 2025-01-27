# frozen_string_literal: true

module Avo
  module Concerns
    module ControlsConfiguration
      extend ActiveSupport::Concern

      unless defined?(ROW_CONTROLS_CONFIG_DEFAULTS)
        ROW_CONTROLS_CONFIG_DEFAULTS = {
          float: false,
          show_on_hover: false
        }.freeze
      end

      included do
        class_attribute :row_controls_config, default: ROW_CONTROLS_CONFIG_DEFAULTS
      end

      def controls_placement_calculated
        @controls_placement_calculated ||= row_controls_configurations[:placement] || Avo.configuration.resource_controls_placement
      end

      def resource_controls_render_on_the_right?
        controls_placement_calculated == :right || resource_controls_render_on_both_sides?
      end

      def resource_controls_render_on_the_left?
        controls_placement_calculated == :left || resource_controls_render_on_both_sides?
      end

      def row_controls_configurations
        ROW_CONTROLS_CONFIG_DEFAULTS.merge(row_controls_config)
      end

      def row_controls_classes
        classes = "text-right whitespace-nowrap px-3"

        if resource_controls_render_on_the_left?
          classes += " w-px"
        end

        if row_controls_configurations[:show_on_hover]
          classes += " opacity-0 group-hover:opacity-100"
        end

        if row_controls_configurations[:float]
          classes += " sticky group-hover:bg-gray-50 bg-white inset-auto right-0"
        end

        classes
      end

      private

      def resource_controls_render_on_both_sides?
        controls_placement_calculated == :both
      end
    end
  end
end
