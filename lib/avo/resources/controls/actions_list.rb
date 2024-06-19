module Avo
  module Resources
    module Controls
      class ActionsList < BaseControl
        ACTIONS_LIST_DROPDOWN_ICON = "heroicons/outline/arrow-down-circle" unless defined?(ACTIONS_LIST_DROPDOWN_ICON)

        attr_reader :color, :exclude, :include, :style, :icon

        def initialize(**args)
          super(**args)

          @color = args[:color] || :primary
          @exclude = args[:exclude] || []
          @include = args[:include] || []
          @style = args[:style] || :outline
          @icon = args[:icon] || ACTIONS_LIST_DROPDOWN_ICON
        end
      end
    end
  end
end
