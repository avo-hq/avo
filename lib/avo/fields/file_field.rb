module Avo
  module Fields
    class FileField < BaseField
      attr_accessor :link_to_record
      attr_accessor :is_avatar
      attr_accessor :is_image
      attr_accessor :is_audio
      attr_accessor :direct_upload
      attr_accessor :accept
      attr_reader :display_filename

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @link_to_record = args[:link_to_record].present? ? args[:link_to_record] : false
        @is_avatar = args[:is_avatar].present? ? args[:is_avatar] : false
        @is_image = args[:is_image].present? ? args[:is_image] : @is_avatar
        @is_audio = args[:is_audio].present? ? args[:is_audio] : false
        @direct_upload = args[:direct_upload].present? ? args[:direct_upload] : false
        @accept = args[:accept].present? ? args[:accept] : nil
        @display_filename = args[:display_filename].nil? ? true : args[:display_filename]
      end

      def path
        rails_blob_url value
      end

      def value
        final_value = super
        # On edit view always show the persisted image. Related: issue#3008
        if final_value.instance_of?(ActiveStorage::Attached::One) && view == "edit"
          persisted_record = record.class.find_by(id: record.id)
          final_value = persisted_record.send(@for_attribute || id)
        end
        final_value
      end
    end
  end
end
