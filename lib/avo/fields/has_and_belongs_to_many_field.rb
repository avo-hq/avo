module Avo
  module Fields
    class HasAndBelongsToManyField < HasBaseField
      def initialize(id, **args, &block)
        args[:updatable] = false

        only_on Avo.configuration.resource_default_view

        super(id, **args, &block)
      end

      def view_component_name
        "HasManyField"
      end
    end
  end
end
