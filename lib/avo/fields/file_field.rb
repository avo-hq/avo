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
    end
  end
end
