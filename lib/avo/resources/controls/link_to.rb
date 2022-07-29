module Avo
  module Resources
    module Controls
      class LinkTo < BaseControl
        def initialize(**args)
          super(**args)
        end

        def path
          @args[:path]
        end

        def target
          @args[:target] || nil
        end

        def turbo_frame
          @args[:turbo_frame] || nil
        end
      end
    end
  end
end
