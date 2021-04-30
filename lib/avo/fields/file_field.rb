module Avo
  module Fields
    class FileField < BaseField
      attr_accessor :link_to_resource
      attr_accessor :is_avatar
      attr_accessor :is_image

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @link_to_resource = args[:link_to_resource].present? ? args[:link_to_resource] : false
        @is_avatar = args[:is_avatar].present? ? args[:is_avatar] : false
        @is_image = args[:is_image].present? ? args[:is_image] : @is_avatar
      end

      def path
        rails_blob_url value
      end

      def variant(resize_to_limit: [128, 128])
        value.variant(resize_to_limit: resize_to_limit).processed.service_url
      end

      def to_image
        return variant(resize_to_limit: [320, 320]) if is_image
      end
    end
  end
end
