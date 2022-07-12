module Avo
  module Fields
    class FileField < BaseField
      attr_accessor :link_to_resource
      attr_accessor :is_avatar
      attr_accessor :is_image
      attr_accessor :is_audio
      attr_accessor :direct_upload
      attr_accessor :accept

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @link_to_resource = args[:link_to_resource].present? ? args[:link_to_resource] : false
        @is_avatar = args[:is_avatar].present? ? args[:is_avatar] : false
        @is_image = args[:is_image].present? ? args[:is_image] : @is_avatar
        @is_audio = args[:is_audio].present? ? args[:is_audio] : false
        @direct_upload = args[:direct_upload].present? ? args[:direct_upload] : false
        @accept = args[:accept].present? ? args[:accept] : nil
      end

      def path
        rails_blob_url value
      end
    end
  end
end
