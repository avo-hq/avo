require "json"

module Avo
  module Fields
    class KeyValueField < BaseField
      attr_reader :disable_editing_keys
      attr_reader :disable_adding_rows
      attr_reader :key_label, :value_label, :action_text

      def initialize(id, **args, &block)
        super

        hide_on :index

        @key_label = args[:key_label] || I18n.translate("avo.key_value_field.key")
        @value_label = args[:value_label] || I18n.translate("avo.key_value_field.value")
        @action_text = args[:action_text] || I18n.translate("avo.key_value_field.add_row")
        @delete_text = args[:delete_text] || I18n.translate("avo.key_value_field.delete_row")
        @reorder_text = args[:reorder_text] || I18n.translate("avo.key_value_field.reorder_row")

        if args[:disabled] == true
          @disable_editing_keys = true
          @disable_editing_values = true
          @disable_adding_rows = true
          @disable_deleting_rows = true
        else
          @disable_editing_keys = args[:disable_editing_keys].present? ? args[:disable_editing_keys] : false
          @disable_editing_values = args[:disable_editing_values].present? ? args[:disable_editing_values] : false
          # disabling editing keys also disables adding rows (doesn't take into account the value of disable_adding_rows)
          @disable_adding_rows = if args[:disable_editing_keys].present? && args[:disable_editing_keys] == true
            true
          elsif args[:disable_adding_rows].present?
            args[:disable_adding_rows]
          else
            false
          end
          @disable_deleting_rows = args[:disable_deleting_rows].present? ? args[:disable_deleting_rows] : false
        end

        @suggestions = args[:suggestions]
      end

      def to_permitted_param
        [:"#{id}", "#{id}": {}]
      end

      def parsed_value
        value.to_json
      rescue
        {}
      end

      def options
        {
          key_label: @key_label,
          value_label: @value_label,
          action_text: @action_text,
          delete_text: @delete_text,
          reorder_text: @reorder_text,
          disable_editing_keys: @disable_editing_keys,
          disable_editing_values: @disable_editing_values,
          disable_adding_rows: @disable_adding_rows,
          disable_deleting_rows: @disable_deleting_rows
        }
      end

      # Keys (and optionally values per key) offered as hints while editing.
      # They are never written to the record unless the user picks them.
      #
      #   suggestions: ["Content-Type", "Accept"]
      #   suggestions: {"Content-Type" => ["application/json", "text/html"]}
      #   suggestions: -> { {"Content-Type" => ["application/json"]} }
      #
      # Always returns a hash of key strings to arrays of value strings.
      def suggestions
        @fetched_suggestions ||= begin
          result = Avo::ExecutionContext.new(target: @suggestions, record: record, resource: @resource, view: @view).handle

          case result
          when Hash
            result.to_h { |key, values| [key.to_s, Array.wrap(values).map(&:to_s)] }
          when Array
            result.to_h { |key| [key.to_s, []] }
          else
            {}
          end
        end
      end

      # Reset the memoized suggestions so a hydrated field evaluates them against the new record
      def hydrate(...)
        @fetched_suggestions = nil

        super
      end

      def fill_field(record, key, value, _params)
        begin
          # The form submits a JSON string, a JSON request body or a tool submits the hash itself
          new_value = value.is_a?(String) ? JSON.parse(value) : value.to_h.stringify_keys
        rescue
          new_value = {}
        end

        old_key_value_hash = record.send(key)
        new_value = apply_disabled_options(new_value, old_key_value_hash, record)

        # Try to cast the new values to the same class as the original value
        if old_key_value_hash.is_a?(Hash)
          old_key_value_hash.transform_keys!(&:to_s)

          new_value.each do |key, value|
            old_value = old_key_value_hash[key.to_s]

            try do
              new_value[key.to_s] = if [TrueClass, FalseClass].include?(old_value.class)
                if value == "true"
                  true
                elsif value == "false"
                  false
                else
                  value
                end
              else
                Kernel.public_send(old_value.class.name, value)
              end
            rescue
              new_value[key.to_s] = value
            end
          end
        end

        record.send(:"#{key}_will_change!") if record.respond_to?(:"#{key}_will_change!")
        record.send(:"#{key}=", new_value)

        record
      end

      private

      # The inputs are only disabled in the browser, so hold the submitted value to the same rules
      def apply_disabled_options(submitted, stored, record)
        return submitted unless @disable_adding_rows || @disable_deleting_rows || @disable_editing_values

        # The new form shows the default when there's no stored value, so that's what the user started from
        stored = computed_default_value if stored.nil? && record.try(:new_record?)
        submitted = {} unless submitted.is_a?(Hash)
        stored = stored.is_a?(Hash) ? stored.transform_keys(&:to_s) : {}

        submitted = submitted.select { |key, _| stored.key?(key) } if @disable_adding_rows
        submitted = submitted.merge(stored.except(*submitted.keys)) if @disable_deleting_rows
        submitted = submitted.to_h { |key, _| [key, stored.fetch(key, "")] } if @disable_editing_values

        submitted
      end
    end
  end
end
