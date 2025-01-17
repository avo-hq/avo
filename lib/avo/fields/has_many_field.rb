module Avo
  module Fields
    class HasManyField < ManyFrameBaseField
      def translated_name(default:)
        t(translation_key, count: 2, default: default_name).capitalize
      end
    end
  end
end
