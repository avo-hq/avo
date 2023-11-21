module Avo
  module Fields
    module Concerns
      module IsDisabled
        extend ActiveSupport::Concern

        attr_reader :disabled

        def is_disabled?
          Avo::ExecutionContext.new(target: disabled, record: record, view: view, resource: resource).handle
        end
      end
    end
  end
end
