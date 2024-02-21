module Avo
  module Fields
    module Concerns
      module ReloadIcon
        extend ActiveSupport::Concern

        included do
          attr_accessor :reloadable
        end

        def reloadable?
          Avo::ExecutionContext.new(target: @reloadable).handle
        end
      end
    end
  end
end
