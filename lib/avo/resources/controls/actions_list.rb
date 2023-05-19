module Avo
  module Resources
    module Controls
      class ActionsList < BaseControl
        def exclude
          Array.wrap(@args[:exclude]) || []
        end

        def include
          Array.wrap(@args[:include]) || []
        end

        def color
          @args[:color] || :primary
        end

        def style
          @args[:style] || :outline
        end
      end
    end
  end
end
