module Avo
  # = Avo Dynamic Config Provider
  #
  # Core seam for the dynamic runtime-configuration overlay (shipped by the
  # commercial +avo-dynamic_config+ gem). Core ships only this *null* provider:
  # with no real provider registered, every seam is a no-op and Avo behaves
  # exactly as it does from its Ruby config files (R1). The commercial gem
  # registers a real provider on the +:avo_boot+ load hook; the seams then
  # consult it per request.
  #
  # == Registration
  #
  #   Avo.register_dynamic_config_provider(MyProvider.new)  # gem, on :avo_boot
  #   Avo.dynamic_config_provider                           # current provider
  #   Avo.dynamic_config_provider_installed?                # single guard predicate
  #
  # +Avo.boot+ resets the provider before running +:avo_boot+ hooks, so a dev
  # reload starts from the null provider and the gem re-registers cleanly.
  #
  # == Protocol (directional)
  #
  # A provider answers "no change" for anything it does not override:
  #
  # * +entity_options_for(entity_ref)+ — option overrides for a resource class
  #   (used both from the instance seam and the class-level read wrappers);
  #   returns a Hash (empty = no change).
  # * +items_for(resource_instance)+ — mutate the per-instance +items_holder+
  #   (add/edit/remove/reorder fields) after +fetch_fields+ ran; return value
  #   ignored.
  # * +attachables_for(resource_instance, kind)+ — extra action/filter/scope
  #   definitions to inject into the per-instance loader bag; returns an Array.
  # * +config_value(key, file_value)+ — overlay value for a configuration key, or
  #   the +NO_CHANGE+ sentinel when not overridden.
  # * +locked?(target)+ — provider-side lock opinion (core enforces its own locks
  #   independently, so this only *adds* locks).
  # * +cache_fingerprint(resource_class)+ — a value mixed into the index/grid
  #   fragment +cache_hash+ so overlay changes bust those caches; +nil+ = no
  #   change to today's key.
  #
  # == Locks (R28)
  #
  # A set of options/keys can never be overridden by the overlay. Locks are
  # enforced *core-side* in every seam, so they hold even against a buggy or
  # hostile provider. The class methods below are the authoritative check; the
  # provider's +locked?+ can only add to them.
  class DynamicConfigProvider
    # Guarded so the Avo dev reloader (which `load`s every lib/avo file on each
    # reload) does not re-initialize these constants and warn — same idiom as
    # lib/avo/version.rb and lib/avo/lambda_registry.rb. Keeping NO_CHANGE
    # identity stable across reloads also keeps `== NO_CHANGE` comparisons valid.
    unless const_defined?(:NO_CHANGE)
      # Returned by #config_value when a key is not overridden. A distinct object
      # (not nil/file_value) so an overlay may legitimately set a value equal to
      # the file value without it reading as "no change".
      NO_CHANGE = Object.new
      def NO_CHANGE.inspect = "Avo::DynamicConfigProvider::NO_CHANGE"
      NO_CHANGE.freeze

      # Configuration keys the overlay can never override (R28). Locked
      # core-side: authentication, identity, authorization wiring, and the
      # license key — overriding any of these would be privilege escalation.
      DEFAULT_LOCKED_CONFIG_KEYS = %i[
        current_user
        current_user_method
        authenticate
        authenticate_with
        authorization_client
        authorization_methods
        explicit_authorization
        is_admin_method
        is_developer_method
        license_key
        raise_error_on_missing_policy
        authorization_enabled
      ].freeze

      # Resource options the overlay can never override (R28). The policy class
      # decides authorization, so it is locked like the config-level auth wiring.
      DEFAULT_LOCKED_RESOURCE_OPTIONS = %i[
        authorization_policy
      ].freeze
    end

    class << self
      # Is this configuration key locked against overlay overrides? Combines the
      # core default-locked set (R28) with the app's `config.locked_config_keys`.
      def config_key_locked?(key)
        key = key.to_sym
        DEFAULT_LOCKED_CONFIG_KEYS.include?(key) ||
          Array(Avo.configuration.locked_config_keys).map(&:to_sym).include?(key)
      end

      # Is this resource option in the core default-locked set (R28)? Per-resource
      # locks (`self.locked_options`) are layered on top by the resource itself.
      def default_locked_resource_option?(option)
        DEFAULT_LOCKED_RESOURCE_OPTIONS.include?(option.to_sym)
      end
    end

    # === Null protocol — every method answers "no change" ===

    # Real providers return +true+; the single guard predicate
    # +Avo.dynamic_config_provider_installed?+ relies on a registration flag, not
    # on this, but a real provider should still say so.
    def installed? = false

    def entity_options_for(entity_ref) = {}

    def items_for(resource_instance) = nil

    def attachables_for(resource_instance, kind) = []

    def config_value(key, file_value) = NO_CHANGE

    def locked?(target) = false

    def cache_fingerprint(resource_class) = nil
  end
end
