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
        float_classes = "bg-white
          group-hover:bg-gray-50
          sticky inset-auto end-0

          before:content-[''] before:absolute before:z-10 before:inset-auto before:start-0 before:top-0 before:mt-0 before:-translate-x-full before:w-3 before:h-full
          before:bg-gradient-to-r
          before:from-transparent before:to-white
          group-hover:before:from-transparent group-hover:before:to-gray-50
        "

        # TODO: add this to the css classes above
        # &:has([data-toggle-target="panel"]:not(.hidden)) {
        #   @apply z-30 opacity-100
        # }

        class_names(
          "text-end whitespace-nowrap px-3",
          "w-px": render_row_controls_on_the_left?,
          "*:opacity-0 group-hover:*:opacity-100": row_controls_configurations[:show_on_hover],
          "#{float_classes}": row_controls_configurations[:float]
        )
      end
    end
  end
end
