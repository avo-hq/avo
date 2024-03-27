module Avo
  module Fields
    class TrixField < BaseField
      attr_reader :always_show
      attr_reader :attachments_disabled
      attr_reader :attachment_key
      attr_reader :hide_attachment_filename
      attr_reader :hide_attachment_filesize
      attr_reader :hide_attachment_url

      def initialize(id, **args, &block)
        super(id, **args, &block)

        hide_on :index

        @always_show = args[:always_show] || false
        @attachment_key = args[:attachment_key]
        @attachments_disabled = disable_attachments?(args)
        @hide_attachment_filename = args[:hide_attachment_filename] || false
        @hide_attachment_filesize = args[:hide_attachment_filesize] || false
        @hide_attachment_url = args[:hide_attachment_url] || false
      end

      # Identify if field is bonded to a rich text model attribute
      def is_action_text?
        return false if record.nil? || !record.respond_to?(id)

        record.send(id).is_a?(ActionText::RichText)
      end

      private

      def disable_attachments?(args)
        # If we don't have an attachment_key, we disable attachments. There's no point in having
        # attachments if we can't store them.
        return false if args[:attachment_key].present?

        args[:attachments_disabled] == true
      end
    end
  end
end
