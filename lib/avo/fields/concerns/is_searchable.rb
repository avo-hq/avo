module Avo
  module Fields
    module Concerns
      module IsSearchable
        extend ActiveSupport::Concern

        def is_searchable?
          return false unless defined?(Avo::Pro)

          @searchable && Avo.license.has_with_trial(:searchable_associations)
        end
      end
    end
  end
end
