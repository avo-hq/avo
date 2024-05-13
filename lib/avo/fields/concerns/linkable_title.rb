module Avo
  module Fields
    module Concerns
      module LinkableTitle
        extend ActiveSupport::Concern

        included do
          attr_accessor :linkable
        end

        def linkable?
          Avo::ExecutionContext.new(target: @linkable).handle
        end
      end
    end
  end
end
