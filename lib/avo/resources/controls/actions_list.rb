module Avo
  module Resources
    module Controls
      class ActionsList < BaseControl
        ACTIONS_LIST_DROPDOWN_ICON = "tabler/outline/circle-arrow-down" unless defined?(ACTIONS_LIST_DROPDOWN_ICON)

        attr_reader :color, :exclude, :include, :style, :icon

        def initialize(**args)
          super

          @color = args[:color]
          @exclude = args[:exclude] || []
          @include = args[:include] || []
          @style = args[:style] || :outline
          @icon = args[:icon] || ACTIONS_LIST_DROPDOWN_ICON
        end
      end
    end
  end
end
