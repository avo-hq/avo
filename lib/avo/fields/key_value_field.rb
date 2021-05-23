require "json"

module Avo
  module Fields
    class KeyValueField < BaseField
      attr_reader :key_label
      attr_reader :value_label
      attr_reader :action_text
      attr_reader :delete_text
      attr_reader :disable_editing_keys
      attr_reader :disable_adding_rows

      def initialize(id, **args, &block)
        super(id, **args, &block)

        hide_on :index

        @key_label = args[:key_label].present? ? args[:key_label].to_s : "Key"
        @value_label = args[:value_label].present? ? args[:value_label].to_s : "Value"
        @action_text = args[:action_text].present? ? args[:action_text].to_s : "Add row"
        @delete_text = args[:delete_text].present? ? args[:delete_text].to_s : "Delete row"

        @disable_editing_keys = args[:disable_editing_keys].present? ? args[:disable_editing_keys] : false
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
          disable_editing_keys: @disable_editing_keys,
          disable_adding_rows: @disable_adding_rows,
          disable_deleting_rows: @disable_deleting_rows
        }
      end

      def fill_field(model, key, value, params)
        begin
          new_value = JSON.parse(value)
        rescue
          new_value = {}
        end

        model[key] = new_value

        model
      end
    end
  end
end
