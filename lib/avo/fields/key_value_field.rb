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

      def fill_field(record, key, value, _params)
        begin
          new_value = JSON.parse(value)
        rescue
          new_value = {}
        end

        # Try to cast the new values to the same class as the original value
        record.send(key).each do |key, value|
          new_value_for_current_key = new_value[key.to_s]

          try do
            # Since ruby doesn't have a boolean type, we need some extra logic to handle it
            new_value[key.to_s] = if [TrueClass, FalseClass].include?(value.class)
              if new_value_for_current_key == "true"
                true
              elsif new_value_for_current_key == "false"
                false
              else
                new_value_for_current_key
              end
            else
              # This is something like Integer("1") or Float("1.2"), etc...
              Kernel.public_send(value.class.name, new_value_for_current_key)
            end
          rescue
            new_value[key.to_s] = new_value_for_current_key
          end
        end

        record.send(:"#{key}_will_change!") if record.respond_to?(:"#{key}_will_change!")
        record.send(:"#{key}=", new_value)

        record
      end
    end
  end
end
