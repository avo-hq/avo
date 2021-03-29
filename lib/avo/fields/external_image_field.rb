module Avo
  module Fields
    class ExternalImageField < BaseField
      attr_reader :width
      attr_reader :height
      attr_reader :radius

      def initialize(name, **args, &block)
        @defaults = {
          partial_name: "external-image-field",
          computable: true
        }.merge(@defaults || {})

        super(name, **args, &block)

        @link_to_resource = args[:link_to_resource].present? ? args[:link_to_resource] : false

        @width = args[:width].present? ? args[:width] : 32
        @height = args[:height].present? ? args[:height] : 32
        @radius = args[:radius].present? ? args[:radius] : 0
      end
    end
  end
end
