# frozen_string_literal: true

module Avo
  class Configuration
    module ResourceConfiguration
      def resource_controls_placement=(val)
        @resource_controls_placement_instance = val
      end

      def resource_controls_placement
        @resource_controls_placement_instance || :right
      end
    end
  end
end
