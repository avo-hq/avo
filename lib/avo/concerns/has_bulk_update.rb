module Avo
  module Concerns
    # Per-resource opt-in for the bulk-update feature.
    #
    # Usage:
    #
    #   class Avo::Resources::Ticket < Avo::BaseResource
    #     self.bulk_update = {
    #       enabled: true,
    #       fields: [:stage, :priority],   # optional allowlist
    #       except: [:archived_at],         # optional denylist
    #       change_summary: true,           # default true
    #       max_records: 1_000,             # overrides Avo.configuration.bulk_update_max_records
    #       sample_threshold: 5,            # overrides Avo.configuration.bulk_update_sample_threshold
    #       handle_bulk_update: -> (records:, attributes:, current_user:) {
    #         # Must return { updated_ids: [...], failed: [{id:, reason:, message:?}, ...] }.
    #         # Framework validates the return shape and raises ArgumentError on mismatch.
    #       }
    #     }
    #   end
    #
    # The reader normalizes nil to {} (so subclass mutations cannot leak into the parent's default)
    # and returns frozen / duped values from accessor methods so in-place mutation of returned arrays
    # cannot leak across subclasses either.
    module HasBulkUpdate
      extend ActiveSupport::Concern

      included do
        # NOTE: no default. Hash defaults on class_attribute leak subclass mutations to the parent.
        # See docs/plans/2026-05-29-001-feat-bulk-update-plan.md "DSL footgun" decision.
        class_attribute :bulk_update
      end

      # Risky field types that don't bulk-edit safely (R4).
      unless defined? AUTO_EXCLUDED_FIELD_TYPES
        AUTO_EXCLUDED_FIELD_TYPES = %w[
          file
          files
          has_many
          has_and_belongs_to_many
          key_value
          password
        ].freeze
      end

      def bulk_update_config
        bulk_update || {}
      end

      def bulk_update_enabled?
        !!bulk_update_config[:enabled]
      end

      def bulk_update_fields
        Array(bulk_update_config[:fields]).dup
      end

      def bulk_update_except
        Array(bulk_update_config[:except]).dup
      end

      def bulk_update_change_summary
        # Default true: change summary renders unless dev explicitly opts out.
        bulk_update_config.fetch(:change_summary, true)
      end

      def bulk_update_max_records
        # Resolution order documented in the plan: resource DSL > global config > hard-coded 500.
        bulk_update_config[:max_records] || Avo.configuration.bulk_update_max_records
      end

      def bulk_update_sample_threshold
        bulk_update_config[:sample_threshold] || Avo.configuration.bulk_update_sample_threshold
      end

      # Returns the validated callable for the optional override, or nil if unset.
      # Raises ArgumentError if the developer assigned a non-callable (Symbol, String, etc.) -
      # Avo::ExecutionContext would otherwise silently return that value and do nothing.
      def handle_bulk_update_callable
        callable = bulk_update_config[:handle_bulk_update]
        return nil if callable.nil?
        return callable if callable.respond_to?(:call)

        raise ArgumentError, "#{self.class}.bulk_update[:handle_bulk_update] must be a Proc, lambda, or Method object. Got #{callable.class}. Example: ->(records:, attributes:, current_user:) { ... }"
      end

      # Single source of truth for "which field ids may be bulk-edited".
      # Both the GET (form rendering) and the POST (allowlist filter) call this method so they
      # cannot drift. Returns a frozen Array<Symbol>.
      def bulk_updatable_field_ids(current_user: Avo::Current.user)
        candidates = get_field_definitions
          .select(&:updatable)
          .reject { |f| AUTO_EXCLUDED_FIELD_TYPES.include?(f.type.to_s) }
          .reject { |f| auto_excluded_special_case?(f) }
          .map { |f| f.id.to_sym }

        if bulk_update_fields.any?
          candidates &= bulk_update_fields.map(&:to_sym)
        end

        candidates -= bulk_update_except.map(&:to_sym)

        candidates.freeze
      end

      private

      # has_one fields with `nested:` submit nested attributes; these aren't safe for bulk update.
      # Other field types are auto-excluded by their `type`, but has_one's risky shape only
      # appears when configured with `nested:`.
      def auto_excluded_special_case?(field)
        return true if field.type.to_s == "has_one" && field.respond_to?(:nested) && field.nested

        false
      end
    end
  end
end
