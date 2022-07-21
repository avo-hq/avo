module Avo
  module Resources
    module Controls
      class ActionsList < BaseControl
        def initialize(filter_out: [], **args)
          @filter_out = filter_out
        end
      end
    end
  end
end
