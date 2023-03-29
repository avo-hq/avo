module Avo
  module Fields
    module Concerns
      module UseResource
        extend ActiveSupport::Concern

        def use_resource
          App.get_resource @use_resource
        end
      end
    end
  end
end
