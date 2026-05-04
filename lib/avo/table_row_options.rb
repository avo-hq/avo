module Avo
  # Resolves and merges user-provided <tr> options from `self.table_view = { row_options: ... }`
  # against the attributes Avo's TableRowComponent sets by default.
  #
  # Public API:
  #
  #   Avo::TableRowOptions.merge(
  #     avo_attributes: { id:, class:, data: },
  #     user_options: resource.class.table_view&.dig(:row_options),
  #     record:, resource:, view:
  #   )
  #
  # See docs/brainstorms/2026-05-04-resource-table-view-row-options-requirements.md
  # and docs/plans/2026-05-05-001-feat-table-view-row-options-plan.md.
  class TableRowOptions
    unless defined?(RESERVED_DATA_KEYS)
      # Data attribute keys Avo owns and reserves on <tr>. User attempts to set
      # these (other than the token-list keys below) are dropped with a warning.
      RESERVED_DATA_KEYS = %i[
        index component_name resource_name record_id resource_id
        visit_path reorder_target
      ].freeze

      # Data attribute keys whose values are space-separated Stimulus token lists.
      # User-provided tokens are concatenated with Avo's, never replaced.
      TOKEN_LIST_DATA_KEYS = %i[controller action].freeze

      # Top-level HTML attributes users may not set on <tr>. Avo owns id;
      # role/aria-selected break <table> semantics or Avo's selection state;
      # the rest are behavior-injection vectors.
      DENIED_KEYS = %i[id role tabindex contenteditable draggable].freeze

      SUPPORTED_KEYS_HINT =
        "class, data, style, title, aria-* (except aria-selected), " \
        "and other passthrough HTML attributes".freeze
    end

    def self.merge(avo_attributes:, user_options:, record:, resource:, view:)
      new(
        avo_attributes: avo_attributes,
        user_options: user_options,
        record: record,
        resource: resource,
        view: view
      ).merge
    end

    def initialize(avo_attributes:, user_options:, record:, resource:, view:)
      @avo_attributes = avo_attributes
      @user_options = user_options
      @record = record
      @resource = resource
      @view = view
    end

    def merge
      do_merge
    rescue => error
      raise unless Rails.env.production?

      Avo.logger.error(format_error(error))
      @avo_attributes
    end

    private

    def do_merge
      resolved = resolve_top_level
      return @avo_attributes if resolved.empty?

      enforce_denylist!(resolved)
      resolved = resolve_per_value(resolved)
      build_merged(resolved)
    end

    def resolve_top_level
      raw = @user_options
      raw = evaluate(raw) if raw.respond_to?(:call)
      raw = {} if raw.nil?

      unless raw.is_a?(Hash)
        raise ArgumentError, "row_options must resolve to a Hash; got #{raw.class}"
      end

      raw
    end

    def resolve_per_value(hash)
      hash.transform_values { |value| value.respond_to?(:call) ? evaluate(value) : value }
    end

    def evaluate(target)
      Avo::ExecutionContext.new(
        target: target,
        record: @record,
        resource: @resource,
        view: @view
      ).handle
    end

    def enforce_denylist!(hash)
      offending = hash.keys.select { |key| denied_key?(key) }
      return if offending.empty?

      raise ArgumentError,
        "[Avo::TableRowOptions] Unsupported row_options keys: #{offending.inspect}. " \
        "Supported: #{SUPPORTED_KEYS_HINT}."
    end

    def denied_key?(key)
      key_str = key.to_s
      return true if DENIED_KEYS.include?(key.to_sym)
      return true if key_str.start_with?("on")
      return true if key_str == "aria-selected"
      false
    end

    def build_merged(user_hash)
      result = @avo_attributes.dup
      user_hash.each do |key, value|
        case key
        when :class
          result[:class] = merge_class(result[:class], value)
        when :data
          result[:data] = merge_data(result[:data] || {}, value)
        else
          apply_passthrough!(result, key, value)
        end
      end
      result
    end

    def merge_class(avo_class, user_value)
      case user_value
      when nil, false
        avo_class
      when String, Symbol
        helpers.class_names(avo_class, user_value.to_s)
      when Array, Hash
        helpers.class_names(avo_class, user_value)
      else
        raise ArgumentError,
          "row_options[:class] must be String, Symbol, Array, Hash, nil, or false; got #{user_value.class}"
      end
    end

    def merge_data(avo_data, user_value)
      unless user_value.is_a?(Hash)
        raise ArgumentError, "row_options[:data] must resolve to a Hash; got #{user_value.class}"
      end

      result = avo_data.dup
      user_value.each do |key, value|
        sym_key = key.to_sym
        if TOKEN_LIST_DATA_KEYS.include?(sym_key)
          coerced = coerce_attribute_value!(:"data.#{key}", value)
          result[sym_key] = concat_tokens(result[sym_key], coerced) unless coerced.nil?
        elsif RESERVED_DATA_KEYS.include?(sym_key)
          warn_reserved_data_key(sym_key)
        else
          coerced = coerce_attribute_value!(:"data.#{key}", value)
          if coerced.nil?
            result.delete(sym_key)
          else
            result[sym_key] = coerced
          end
        end
      end
      result
    end

    def apply_passthrough!(result, key, value)
      coerced = coerce_attribute_value!(key, value)
      if coerced.nil?
        result.delete(key)
      else
        result[key] = coerced
      end
    end

    def coerce_attribute_value!(key, value)
      case value
      when nil, false
        nil
      when String
        value
      when Symbol, Integer
        value.to_s
      else
        raise ArgumentError,
          "row_options[#{key.inspect}] must return String, Symbol, Integer, nil, or false; got #{value.class}"
      end
    end

    def warn_reserved_data_key(key)
      return unless Rails.env.development? || Rails.env.test?

      Avo.logger.warn(
        "[Avo::TableRowOptions] data[#{key.inspect}] is a reserved Avo key and was ignored. " \
        "Reserved keys: #{RESERVED_DATA_KEYS.inspect}."
      )
    end

    def concat_tokens(*values)
      values
        .flat_map { |value| value.to_s.split(/\s+/) }
        .reject(&:empty?)
        .uniq
        .join(" ")
    end

    def helpers
      @helpers ||= ActionController::Base.helpers
    end

    def format_error(error)
      "[Avo::TableRowOptions ->] #{error.class}: #{error.message}\n  " +
        Array(error.backtrace).first(3).join("\n  ")
    end
  end
end
