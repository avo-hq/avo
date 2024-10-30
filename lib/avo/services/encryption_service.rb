module Avo
  module Services
    class EncryptionService
      class << self
        def encrypt(...)
          new(...).encrypt
        end

        def decrypt(...)
          new(...).decrypt
        end
      end

      def initialize(message:, purpose:, **kwargs)
        @message = message
        @purpose = purpose
        @crypt = ActiveSupport::MessageEncryptor.new(encryption_key, **kwargs)
      end

      def encrypt
        @crypt.encrypt_and_sign(@message, purpose: @purpose)
      end

      def decrypt
        @crypt.decrypt_and_verify(@message, purpose: @purpose)
      end

      private

      def encryption_key
        Rails.application.secret_key_base[0..31]
      end
    end
  end
end
