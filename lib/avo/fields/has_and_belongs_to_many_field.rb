module Avo
  module Fields
    class HasAndBelongsToManyField < HasManyBaseField

      class_attribute :supported_options, default: {}
      Avo::Fields::COMMON_OPTIONS.each do |common_option, hash|
        supports common_option, hash
      end

      def view_component_name
        "HasManyField"
      end
    end
  end
end
