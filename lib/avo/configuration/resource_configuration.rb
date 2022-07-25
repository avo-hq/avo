module Avo
  class Configuration
    module ResourceConfiguration
      def resource_controls_placement=(val)
        @resource_controls_placement_instance = val
      end

      def resource_controls_placement
        @resource_controls_placement_instance || :right
      end

      def resource_controls_on_the_left?
        resource_controls_placement.to_s == 'left'
      end

      def resource_controls_on_the_right?
        resource_controls_placement.to_s == 'right'
      end
    end
  end
end
