module Avo
  module Resources
    module Controls
      class ActionsList < BaseControl
        attr_reader :color, :exclude, :include, :style

        def initialize(**args)
          super(**args)

          @color = args[:color] || :primary
          @exclude = args[:exclude] || []
          @include = args[:include] || []
          @style = args[:style] || :outline
        end
      end
    end
  end
end
