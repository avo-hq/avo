module Avo
  module Services
    class EncryptionService
      attr_reader :message
      attr_reader :purpose
      attr_reader :crypt

      class << self
        def encrypt(message:, purpose:)
          new(message: message, purpose: purpose).encrypt
        end

        def decrypt(message:, purpose:)
          new(message: message, purpose: purpose).decrypt
        end
      end

      def initialize(message:, purpose:)
        @message = message
        @purpose = purpose
        @crypt = ActiveSupport::MessageEncryptor.new(encryption_key)
      end

      def encrypt
        crypt.encrypt_and_sign(message, purpose: purpose)
      end

      def decrypt
        crypt.decrypt_and_verify(message, purpose: purpose)
      end

      private

      def encryption_key
        secret_key_base[0..31]
      rescue
        # This will fail the decryption process.
        # It's here only to keep Avo from crashing
        SecureRandom.random_bytes(32)
      end

      def secret_key_base
        Rails.application.secrets.secret_key_base || ENV['SECRET_KEY_BASE']
      end
    end
  end
end
