module Avo
  module Fields
    class HasManyField < HasManyBaseField
      def translated_name(default:)
        t(translation_key, count: 2, default: default_name).capitalize
      end
    end
  end
end
