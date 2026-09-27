module Avo
  module Fields
    class FilesField < BaseField
      attr_accessor :direct_upload
      attr_accessor :accept
      attr_reader :display_filename
      attr_reader :lightbox
      attr_reader :view_type
      attr_reader :hide_view_type_switcher

      def initialize(id, **args, &block)
        super

        @direct_upload = args[:direct_upload].present? ? args[:direct_upload] : false
        @accept = args[:accept].present? ? args[:accept] : nil
        @display_filename = args[:display_filename].nil? || args[:display_filename]
        @lightbox = args[:lightbox].nil? || args[:lightbox]
        @view_type = args[:view_type] || :grid
        @hide_view_type_switcher = args[:hide_view_type_switcher]
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

      def view_component_name
        "FilesField"
      end

      def to_permitted_param
        {"#{id}": []}
      end

      def fill_field(record, key, value, params)
        return record unless record.methods.include? key.to_sym

        # attach files in one call to avoid index_active_storage_attachments_uniqueness violation
        record.send(key).attach(value.compact_blank)

        record
      end

      def tooltip_anchor
        :block
      end
    end
  end
end
