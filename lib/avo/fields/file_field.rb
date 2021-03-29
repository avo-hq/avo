module Avo
  module Fields
    class FileField < BaseField
      attr_accessor :is_avatar
      attr_accessor :is_image

      def initialize(name, **args, &block)
        @defaults = {
          partial_name: "file-field"
        }.merge(@defaults || {})

        super(name, **args, &block)

        @file_field = true
        @is_avatar = args[:is_avatar].present? ? args[:is_avatar] : false
        @is_image = args[:is_image].present? ? args[:is_image] : @is_avatar
        @link_to_resource = args[:link_to_resource].present? ? args[:link_to_resource] : false
      end

      def path
        rails_blob_url value
      end

      def variant(resize_to_limit: [128, 128])
        value.variant(resize_to_limit: resize_to_limit).processed.service_url
      end
    end
  end
end
