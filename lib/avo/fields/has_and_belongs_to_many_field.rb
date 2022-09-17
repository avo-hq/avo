module Avo
  module Fields
    class HasAndBelongsToManyField < HasBaseField
      def initialize(id, **args, &block)
        args[:updatable] = false

        hide_on :all
        show_on :show

        super(id, **args, &block)
      end

      def view_component_name
        "HasManyField"
      end
    end
  end
end
