module Avo
  module Fields
    class HasManyField < HasManyBaseField

      class_attribute :supported_options, default: {}
      Avo::Fields::COMMON_OPTIONS.each do |common_option, hash|
        supports common_option, hash
      end

      def translated_name(default:)
        t(translation_key, count: 2, default: default_name).capitalize
      end
    end
  end
end
