module Avo
  module Fields
    module Concerns
      module HasDefault
        extend ActiveSupport::Concern

        def computed_default_value
          Avo::ExecutionContext.new(target: default, record: record, view: view, resource: resource).handle
        end
      end
    end
  end
end
