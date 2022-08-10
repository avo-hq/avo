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

        def data
          @args[:data] || {}
        end

        def class
          @args[:class] || nil
        end
      end
    end
  end
end
