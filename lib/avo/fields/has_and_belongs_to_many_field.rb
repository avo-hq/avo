module Avo
  module Fields
    class HasAndBelongsToManyField < HasBaseField
      def initialize(id, **args, &block)
        args[:updatable] = false

        super(id, **args, &block)

        hide_on :all
        show_on :show
      end

      def view_component_name
        "HasManyField"
      end
    end
  end
end
