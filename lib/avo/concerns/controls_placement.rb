# frozen_string_literal: true

module Avo
  module Concerns
    module ControlsPlacement
      extend ActiveSupport::Concern

      def controls_placement_calculated
        @controls_placement_calculated ||= controls_placement || Avo.configuration.resource_controls_placement
      end

      def resource_controls_render_on_the_right?
        controls_placement_calculated == :right || resource_controls_render_on_both_sides?
      end

      def resource_controls_render_on_the_left?
        controls_placement_calculated == :left || resource_controls_render_on_both_sides?
      end

      private

      def resource_controls_render_on_both_sides?
        controls_placement_calculated == :both
      end
    end
  end
end
