module Avo
  module Fields
    module Concerns
      module IsReadonly
        extend ActiveSupport::Concern

        def is_readonly?
          Avo::ExecutionContext.new(target: readonly, record: record, view: view, resource: resource).handle
        end
      end
    end
  end
end
