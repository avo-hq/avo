module Avo
  module Fields
    class HasAndBelongsToManyField < HasManyBaseField
      def view_component_name
        "HasManyField"
      end
    end
  end
end
