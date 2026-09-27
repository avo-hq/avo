module Avo
  module Fields
    class FileField < BaseField
      attr_accessor :link_to_record
      attr_accessor :is_avatar
      attr_accessor :direct_upload
      attr_accessor :accept
      attr_reader :display_filename
      attr_reader :lightbox

      def initialize(id, **args, &block)
        super

        @link_to_record = args[:link_to_record].present? ? args[:link_to_record] : false
        @is_avatar = args[:is_avatar].present? ? args[:is_avatar] : false
        @direct_upload = args[:direct_upload].present? ? args[:direct_upload] : false
        @accept = args[:accept].present? ? args[:accept] : nil
        @display_filename = args[:display_filename].nil? || args[:display_filename]
        @lightbox = args[:lightbox].nil? || args[:lightbox]
      end

      # Images open in an in-page lightbox on the Show view unless the field opts
      # out with `lightbox: false`. Forms keep their thumbnails plain.
      def lightbox?
        lightbox && view.show?
      end

      # Whether +attachment+ opens in the lightbox: the field allows it and the
      # attachment is an image the browser can display. Takes the attachment
      # record, or the `has_one_attached` proxy a file field's value is.
      def lightbox_for?(attachment)
        attachment = attachment.attachment if attachment.is_a?(ActiveStorage::Attached::One)

        lightbox? && attachment&.blob.present? && attachment.representable? && attachment.image?
      end

      def path
        rails_blob_url value
      end

      def value
        final_value = super

        # On edit view always show the persisted image. Related: issue#3008
        # Only a pending attachment change (a failed update) differs from the database, so re-find only then.
        if final_value.instance_of?(ActiveStorage::Attached::One) && @view.edit? && @record.attachment_changes.key?(attribute_id.to_s)
          persisted_record = @resource.find_record(@record.to_param)
          final_value = persisted_record.send(attribute_id)
        end

        final_value
      end
    end
  end
end
