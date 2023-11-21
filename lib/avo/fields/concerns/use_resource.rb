module Avo
  module Fields
    module Concerns
      module UseResource
        extend ActiveSupport::Concern

        def use_resource
          Avo.resource_manager.get_resource @use_resource
        rescue
          # On boot we eager load the resources before the app is set.
          # Because of that, we don't have a resource manager.
          nil
        end
      end
    end
  end
end
