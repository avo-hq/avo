module Avo
  module Fields
    module Concerns
      module IsSearchable
        extend ActiveSupport::Concern

        # Don't remove, avo-pro hooks into this method to check if the field is searchable.
        def is_searchable? = false
      end
    end
  end
end
