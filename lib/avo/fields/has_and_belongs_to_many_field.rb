module Avo
  module Fields
    class HasAndBelongsToManyField < ManyFrameBaseField
      def view_component_name
        "HasManyField"
      end
    end
  end
end
