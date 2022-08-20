module Avo
  module Services
    class EncryptionService < ApplicationService
      attr_reader :message
      attr_reader :purpose
      attr_reader :crypt

      def initialize(message:, purpose:)
        @message = message
        @purpose = purpose
        @crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31])
      end

      def encrypt
        @crypt.encrypt_and_sign(@message, purpose: @purpose)
      end

      def decrypt
        @crypt.decrypt_and_verify(@message, purpose: @purpose)
      end
    end
  end
end
