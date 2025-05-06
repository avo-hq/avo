module Avo
  module Fields
    class TrixField < BaseField
      class_attribute :supported_options, default: {}

      Avo::Fields::COMMON_OPTIONS.each do |common_option, hash|
        supports common_option, hash
      end

      supports :always_show, default: false
      supports :attachment_key
      supports :hide_attachment_filename, default: false
      supports :hide_attachment_filesize, default: false
      supports :hide_attachment_url, default: false

      def post_initialize
        hide_on :index
      end

      # Identify if field is bonded to a rich text model attribute
      def is_action_text?
        return false if !defined?(ActionText::RichText) || record.nil? || !record.respond_to?(id)

        record.send(id).is_a?(ActionText::RichText)
      end

      def attachments_disabled
        # Return the value of attachments_disabled if explicitly provided
        return @attachments_disabled unless @attachments_disabled.nil?

        # By default enable attachments on action text
        return false if is_action_text?

        # Disable attachments if attachment_key is not present
        @attachment_key.blank?
      end
    end
  end
end
