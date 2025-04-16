require "json"

module Avo
  module Fields
    class KeyValueField < BaseField
      attr_reader :disable_editing_keys
      attr_reader :disable_adding_rows
      attr_reader :key_label, :value_label, :action_text

      def initialize(id, **args, &block)
        super(id, **args, &block)

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

        record.send(:"#{key}_will_change!")
        record.send(:"#{key}=", new_value)

        record
      end
    end
  end
end
