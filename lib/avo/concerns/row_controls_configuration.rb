# frozen_string_literal: true

module Avo
  module Concerns
    module RowControlsConfiguration
      extend ActiveSupport::Concern

      included do
        class_attribute :row_controls_config, default: {}
      end

      def controls_placement
        @controls_placement ||= row_controls_configurations[:placement]
      end

      def render_row_controls_on_the_right?
        controls_placement.in? [:right, :both]
      end

      def render_row_controls_on_the_left?
        controls_placement.in? [:left, :both]
      end

      def row_controls_configurations
        @row_controls_configurations ||= Avo.configuration.resource_row_controls_config.merge(row_controls_config)
      end

      def row_controls_classes
        classes = "text-right whitespace-nowrap px-3"

        if render_row_controls_on_the_left?
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
    end
  end
end
