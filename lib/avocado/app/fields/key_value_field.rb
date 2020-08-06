require 'json'

module Avocado
  module Fields
    class KeyValueField < Field
      def initialize(name, **args, &block)
        @defaults = {
          component: 'key-value-field',
        }

        super(name, **args, &block)

        hide_on :index

        @is_object_param = true
        @key_label = args[:key_label].present? ? args[:key_label].to_s : 'Key'
        @value_label = args[:value_label].present? ? args[:value_label].to_s : 'Value'
        @action_text = args[:action_text].present? ? args[:action_text].to_s : 'Add row'
        @delete_text = args[:delete_text].present? ? args[:delete_text].to_s : 'Delete row'

        @disable_editing_keys = args[:disable_editing_keys].present? ? args[:disable_editing_keys] : false
        # disabling editing keys also disables adding rows (doesn't take into account the value of disable_adding_rows)
        if args[:disable_editing_keys].present? && args[:disable_editing_keys] == true
          @disable_adding_rows = true
        elsif args[:disable_adding_rows].present?
          @disable_adding_rows = args[:disable_adding_rows]
        else
          @disable_adding_rows = false
        end
        @disable_deleting_rows = args[:disable_deleting_rows].present? ? args[:disable_deleting_rows] : false
      end

      def hydrate_field(fields, model, resource, view)
        {
          key_label: @key_label,
          value_label: @value_label,
          action_text: @action_text,
          delete_text: @delete_text,
          disable_editing_keys: @disable_editing_keys,
          disable_adding_rows: @disable_adding_rows,
          disable_deleting_rows: @disable_deleting_rows,
        }
      end
    end
  end
end
