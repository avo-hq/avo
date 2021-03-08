module Avo
  module Fields
    class ExternalImageField < Field
      attr_reader :width
      attr_reader :height
      attr_reader :radius

      def initialize(name, **args, &block)
        @defaults = {
          partial_name: 'external-image-field',
          computable: true,
        }.merge(@defaults || {})

        super(name, **args, &block)

        @link_to_resource = args[:link_to_resource].present? ? args[:link_to_resource] : false
        @width = 32
        @height = 32
        @radius = 0
      end
    end
  end
end
