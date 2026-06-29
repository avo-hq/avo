# frozen_string_literal: true

module Avo
  module Fields
    class EncryptedTextField < TextField
      MASK = "••••••••"

      attr_reader :revealable

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @revealable = args.fetch(:revealable, true)
      end

      def masked_value
        MASK
      end

      def encrypted_attribute?
        return false unless record.present? && record.class.respond_to?(:encrypted_attributes)

        record.class.encrypted_attributes.include?(id.to_s)
      end

      def fill_field(record, key, value, params)
        key = @for_attribute.to_s if @for_attribute.present?
        return record unless has_attribute?(record, key)

        # Skip updating if the value is blank to avoid overwriting encrypted data
        # with empty strings. Users must explicitly provide a new value.
        return record if value.blank?

        # Skip if value equals the mask (shouldn't happen, but safety check)
        return record if value == MASK

        record.public_send(:"#{key}=", apply_update_using(record, key, value, resource))
        record
      end
    end
  end
end
