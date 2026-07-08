module Avo
  module Concerns
    module AbstractResource
      extend ActiveSupport::Concern

      class_methods do
        def abstract_resource! = @abstract_resource = true

        def is_abstract? = @abstract_resource == true

        # Rails-style setter. Equivalent to calling `abstract_resource!` —
        # the resource is marked abstract and excluded from the resource
        # manager, so no missing-model warning and it won't show in the UI.
        # Subclasses stay concrete unless they set their own flag.
        def abstract_resource=(value)
          @abstract_resource = value
        end

        def abstract_resource = @abstract_resource == true
      end
    end
  end
end
