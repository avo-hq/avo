require "base64"

module Avo
  module Fields
    class RevealField < BaseField
      attr_reader :mask_length

      def initialize(id, **args, &block)
        super

        # Display-only: secrets should not be editable through this field.
        hide_on :forms

        @mask_length = args[:mask_length] || 8
      end

      # Fixed-length mask so the rendered HTML does not leak the secret's length.
      def mask
        "•" * mask_length
      end

      # Encode the plaintext so a casual DOM inspection does not show the value.
      # Decoded client-side only after the user clicks reveal.
      def encoded_value
        return if value.nil?

        Base64.strict_encode64(value.to_s)
      end
    end
  end
end
