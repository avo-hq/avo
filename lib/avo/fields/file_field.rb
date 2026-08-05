module Avo
  module Fields
    class FileField < BaseField
      attr_accessor :link_to_record
      attr_accessor :is_avatar
      attr_accessor :direct_upload
      attr_accessor :accept
      attr_reader :display_filename

      def initialize(id, **args, &block)
        super

        @link_to_record = args[:link_to_record].present? ? args[:link_to_record] : false
        @is_avatar = args[:is_avatar].present? ? args[:is_avatar] : false
        @direct_upload = args[:direct_upload].present? ? args[:direct_upload] : false
        @accept = args[:accept].present? ? args[:accept] : nil
        @display_filename = args[:display_filename].nil? || args[:display_filename]
      end

      def path
        rails_blob_url value
      end

      def value
        final_value = super

        # On edit view always show the persisted image. Related: issue#3008
        if final_value.instance_of?(ActiveStorage::Attached::One) && @view.edit?
          persisted_record = @resource.find_record(@record.to_param)
          final_value = persisted_record.send(attribute_id)
        end

        final_value
      end
    end
  end
end
