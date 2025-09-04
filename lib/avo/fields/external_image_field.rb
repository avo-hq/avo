module Avo
  module Fields
    class ExternalImageField < BaseField
      attr_reader :link_to_record

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @link_to_record = args[:link_to_record].present? ? args[:link_to_record] : false

        @width = args[:width]
        @height = args[:height]
        @radius = args[:radius]
      end

      def to_image
        value
      end

      def width
        execute_context(@width, default: 40)
      end

      def height
        execute_context(@height, default: 40)
      end

      def radius
        execute_context(@radius, default: 0)
      end

      private

      def execute_context(target, default: nil)
        Avo::ExecutionContext.new(
          target:,
          record: @record,
          resource: @resource,
          view: @view,
          field: self
        ).handle || default
      end
    end
  end
end
