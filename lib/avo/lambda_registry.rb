module Avo
  # = Avo Lambda Registry
  #
  # A public, process-global registry of *named* lambdas. Apps and gems register
  # a lambda under a symbol together with metadata (a human label, a description,
  # and the binding +kinds+ it is allowed to fill — e.g. +:visibility+, +:query+,
  # +:format+, +:scope+). Stored configuration (such as the dynamic-config
  # overlay) then references those lambdas *by name* instead of stuffing code in
  # the database. Evaluation always goes through Avo::ExecutionContext, so a
  # named lambda behaves identically to an inline proc and literal values pass
  # through unchanged.
  #
  # == Reload safety
  #
  # +Avo.boot+ re-runs on every +to_prepare+ (i.e. on every code reload in
  # development), while Rails initializers run only once per process boot. If
  # registrations lived only as direct calls they would be wiped by the first
  # reload and every gating reference would silently fail closed. Two entry
  # points solve this:
  #
  # * <b>declarative</b> (+declare+) — capture a block that re-runs on every
  #   +reset+/boot. This is the initializer-friendly path; use it from
  #   +config/initializers+.
  # * <b>direct</b> (+register+) — add a single entry immediately. This is only
  #   durable when called from something that itself re-runs on boot (an
  #   +:avo_boot+ load hook or a +to_prepare+ block).
  #
  # == Resolution failure semantics
  #
  # +resolve+ takes the *expected* binding kind and a +context+:
  #
  # * +:gating+ — the value decides visibility/authorization. An unknown name or
  #   a kind mismatch returns the fail-closed value (+false+ → hidden/denied) and
  #   is never evaluated.
  # * +:cosmetic+ — the value is presentational. The same failures return the
  #   Avo::LambdaRegistry::SKIP marker (caller falls back to its default) and log
  #   a single warning.
  #
  # Kind binding is enforced at resolve time, not only at write time: a
  # resolvable-but-miskinded reference (e.g. a +:query+ lambda bound to
  # +visible:+) is treated as broken and fails closed, regardless of how it got
  # into the store.
  class LambdaRegistry
    # Guarded so the Avo dev reloader (which `load`s every lib/avo file on each
    # reload) does not re-initialize these constants and warn — same idiom as
    # lib/avo/version.rb. Keeping SKIP identity stable across reloads also keeps
    # `result == SKIP` comparisons valid.
    unless const_defined?(:VALID_KINDS)
      # The binding kinds a lambda may declare. Extend here when a new binding
      # site is introduced.
      VALID_KINDS = %i[visibility query scope format authorization].freeze

      # The resolution contexts a caller may declare.
      VALID_CONTEXTS = %i[gating cosmetic].freeze

      # Value returned by +resolve+ when a gating reference cannot be honoured.
      # Fails closed: hidden for visibility, denied for authorization.
      GATING_FAILURE = false

      # Marker returned by +resolve+ when a cosmetic reference cannot be
      # honoured, signalling the caller to fall back to its own default.
      SKIP = Object.new
      def SKIP.inspect = "Avo::LambdaRegistry::SKIP"
      SKIP.freeze

      Entry = Struct.new(:name, :callable, :label, :description, :kinds)
    end

    # Raised when a lambda is registered with an empty or unknown kind. Fails at
    # registration/boot time rather than at request time.
    class InvalidKindError < StandardError; end

    def initialize
      @entries = {}
      @declarations = []
    end

    # Capture a declarative registration block, replayed on every +reset+ (and
    # therefore on every +Avo.boot+). The block receives the registry:
    #
    #   Avo.lambda_registry.declare do |registry|
    #     registry.register :active_records, label: "Active records",
    #       description: "Only visible records", kinds: [:query] do
    #       query.where(active: true)
    #     end
    #   end
    #
    # The block runs once immediately so the lambda is usable right away, then
    # again on each reset.
    def declare(&block)
      @declarations << block
      block.call(self)
      self
    end

    # Register a single named lambda directly. Durable only when called from a
    # context that re-runs on boot (an +:avo_boot+ load hook or +to_prepare+);
    # from an initializer use +declare+ instead.
    #
    # Raises Avo::LambdaRegistry::InvalidKindError when +kinds+ is empty or names
    # a kind outside VALID_KINDS.
    def register(name, kinds:, label: nil, description: nil, &block)
      name = name.to_sym
      kinds = normalize_kinds(kinds)

      @entries[name] = Entry.new(
        name: name,
        callable: block,
        label: label,
        description: description,
        kinds: kinds
      )

      name
    end

    def registered?(name)
      @entries.key?(name.to_sym)
    end

    def entry(name)
      @entries[name.to_sym]
    end
    alias_method :[], :entry

    # All registered names.
    def names
      @entries.keys
    end

    # The kinds a registered lambda is allowed to fill, or +nil+ when unknown.
    def kinds_for(name)
      entry(name)&.kinds
    end

    # Resolve a reference and evaluate it in the request context.
    #
    # * A Symbol is treated as a *named reference*: it is looked up, its kind is
    #   checked against +kind+, and — on success — evaluated through
    #   Avo::ExecutionContext. Unknown name or kind mismatch fails per +context+.
    # * Anything else (a Proc, or a literal such as a String/Integer/boolean) is
    #   passed straight through Avo::ExecutionContext, preserving literal
    #   passthrough parity with inline configuration.
    #
    # Extra keyword arguments (e.g. +record:+) are forwarded to the execution
    # context, so blocks reach +record+, +current_user+, +params+, etc.
    def resolve(reference, kind:, context: :gating, **execution_context_args)
      validate_context!(context)

      unless reference.is_a?(Symbol)
        return Avo::ExecutionContext.new(target: reference, **execution_context_args).handle
      end

      found = entry(reference)

      if found.nil?
        return failure(context, "Avo::LambdaRegistry: no lambda registered for :#{reference} (#{kind})")
      end

      unless found.kinds.include?(kind.to_sym)
        return failure(
          context,
          "Avo::LambdaRegistry: lambda :#{reference} is not bindable as #{kind} (allowed: #{found.kinds.join(", ")})"
        )
      end

      Avo::ExecutionContext.new(target: found.callable, **execution_context_args).handle
    end

    # Boot behaviour: drop every registered entry and replay the declarative
    # blocks so declarations survive a code reload. Direct +register+ calls made
    # from boot hooks are re-applied by those hooks re-running.
    def reset
      @entries = {}
      @declarations.each { |block| block.call(self) }
      self
    end

    # Full wipe, including declarations. Intended for test teardown; +Avo.boot+
    # uses +reset+, not this.
    def clear!
      @entries = {}
      @declarations = []
      self
    end

    private

    def normalize_kinds(kinds)
      kinds = Array(kinds).map(&:to_sym)

      if kinds.empty?
        raise InvalidKindError, "A registered lambda must declare at least one kind (one of #{VALID_KINDS.join(", ")})"
      end

      invalid = kinds - VALID_KINDS

      if invalid.any?
        raise InvalidKindError, "Invalid lambda kind(s): #{invalid.join(", ")}. Valid kinds: #{VALID_KINDS.join(", ")}"
      end

      kinds
    end

    def validate_context!(context)
      return if VALID_CONTEXTS.include?(context)

      raise ArgumentError, "Invalid resolution context: #{context.inspect}. Valid contexts: #{VALID_CONTEXTS.join(", ")}"
    end

    def failure(context, message)
      if context == :cosmetic
        Avo.logger.warn(message)
        SKIP
      else
        GATING_FAILURE
      end
    end
  end
end
