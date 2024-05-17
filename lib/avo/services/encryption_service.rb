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

      def initialize(message:, purpose:, **)
        @message = message
        @purpose = purpose
        @crypt = ActiveSupport::MessageEncryptor.new(encryption_key, **)
      end

      def encrypt
        @crypt.encrypt_and_sign(@message, purpose: @purpose)
      end

      def decrypt
        @crypt.decrypt_and_verify(@message, purpose: @purpose)
      end

      private

      def encryption_key
        secret_key_base[0..31]
      end

      def secret_key_base
        # Try to fetch the secret key base from ENV or the credentials file
        key = ENV["SECRET_KEY_BASE"] || Rails.application.credentials.secret_key_base

        # If key is blank and Rails version is less than 7.2.0
        # Try to fetch the secret key base from the secrets file
        # Rails 7.2.0 made secret_key_base from secrets obsolete
        if key.blank? && (Rails.gem_version < Gem::Version.new("7.2.0"))
          key = Rails.application.secrets.secret_key_base
        end

        return key if key.present?

        # Avoid breaking in production
        # All features relying on encryption will not work properly without a configured secret key base
        return SecureRandom.random_bytes(32) if Rails.env.production?

        raise "Unable to fetch secret key base. Please set it in your credentials or environment variables\n" \
          "For more information check https://docs.avohq.io/3.0/encryption-service.html#secret-key-base"
      end
    end
  end
end
