module Avo
  module Services
    class ApplicationService
      def self.encrypt(message:, purpose:)
        new(message: message, purpose: purpose).encrypt
      end

      def self.decrypt(message:, purpose:)
        new(message: message, purpose: purpose).decrypt
      end
    end
  end
end
