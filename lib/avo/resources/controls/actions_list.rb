module Avo
  module Resources
    module Controls
      class ActionsList < BaseControl
        attr_reader :color, :exclude, :include, :style, :icon

        def initialize(**args)
          super(**args)

          @color = args[:color] || :primary
          @exclude = args[:exclude] || []
          @include = args[:include] || []
          @style = args[:style] || :outline
          @icon = args[:icon]
        end
      end
    end
  end
end
