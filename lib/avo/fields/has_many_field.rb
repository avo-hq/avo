module Avo
  module Fields
    class HasManyField < HasManyBaseField
      def translated_name(default:)
        translate_field_name(count: 2, default: default_name)
      end
    end
  end
end
