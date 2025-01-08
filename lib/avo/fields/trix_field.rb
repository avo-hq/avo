module Avo
  module Fields
    class TrixField < BaseField
      attr_reader :always_show
      attr_reader :attachment_key
      attr_reader :hide_attachment_filename
      attr_reader :hide_attachment_filesize
      attr_reader :hide_attachment_url

      def initialize(id, **args, &block)
        super(id, **args, &block)

        hide_on :index

        @always_show = args[:always_show] || false
        @attachment_key = args[:attachment_key]
        @attachments_disabled = args[:attachments_disabled]
        @hide_attachment_filename = args[:hide_attachment_filename] || false
        @hide_attachment_filesize = args[:hide_attachment_filesize] || false
        @hide_attachment_url = args[:hide_attachment_url] || false
      end

      # Identify if field is bonded to a rich text model attribute
      def is_action_text?
        return false if !defined?(ActionText::RichText) || record.nil? || !record.respond_to?(id)

        record.send(id).is_a?(ActionText::RichText)
      end

      def attachments_disabled
        # Return the value of attachments_disabled if explicitly provided
        return @attachments_disabled unless @attachments_disabled.nil?
      end
    end
  end
end
