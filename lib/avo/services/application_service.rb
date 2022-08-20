module Avo
  module Services
    class ApplicationService
      def self.encrypt(message:, purpose:)
        new(message:, purpose:).encrypt
      end

      def self.decrypt(message:, purpose:)
        new(message:, purpose:).decrypt
      end
    end
  end
end
