module Avo
  module Fields
    class ArrayField < ManyFrameBaseField

      class_attribute :supported_options, default: {}
      Avo::Fields::COMMON_OPTIONS.each do |common_option, hash|
        supports common_option, hash
      end

      def translated_name(default:)
        t(translation_key, count: 2, default: default_name).capitalize
      end

      def view_component_name
        "HasManyField"
      end

      def resource_class(params)
        use_resource || Avo.resource_manager.get_resource_by_name(@id.to_s)
      end
    end
  end
end
