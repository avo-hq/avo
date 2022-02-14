require "json"

module Avo
  module Fields
    class KeyValueField < BaseField
      attr_reader :disable_editing_keys
      attr_reader :disable_adding_rows

      def initialize(id, **args, &block)
        super(id, **args, &block)

        hide_on :index

        @key_label = args[:key_label].to_s if args[:key_label].present?
        @value_label = args[:value_label].to_s if args[:value_label].present?
        @action_text = args[:action_text].to_s if args[:action_text].present?
        @delete_text = args[:delete_text].to_s if args[:delete_text].present?

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

      def key_label
        return @key_label if @key_label && !@key_label.empty?

        I18n.translate('avo.key_value_field.key')
      end

      def value_label
        return @value_label if @value_label && !@value_label.empty?

        I18n.translate('avo.key_value_field.value')
      end

      def action_text
        return @action_text if @action_text && !@action_text.empty?

        I18n.translate('avo.key_value_field.add_row')
      end

      def delete_text
        return @delete_text if @delete_text && !@delete_text.empty?

        I18n.translate('avo.key_value_field.delete_row')
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
