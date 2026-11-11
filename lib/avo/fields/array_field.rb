module Avo
  module Fields
    class ArrayField < ManyFrameBaseField
      def translated_name(default:)
        translate_field_name(count: 2, default:)
      end

      def view_component_name
        "HasManyField"
      end

      def resource_class(params)
        use_resource || Avo.resource_manager.get_resource_by_name(@id.to_s)
      end

      # There's no Active Record association to reflect on, so the panel lists the resource named after the field.
      def target_resource
        resource_class(nil)
      end
    end
  end
end
