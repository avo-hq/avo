module Avo
  module Fields
    class TagsField < Avo::Fields::BaseField
      attr_reader :acts_as_taggable_on
      attr_reader :close_on_select
      attr_reader :delimiters
      attr_reader :enforce_suggestions
      attr_reader :mode
      attr_reader :suggestions_max_items

      def initialize(id, **args, &block)
        super(id, **args, &block)

        add_boolean_prop args, :close_on_select
        add_boolean_prop args, :enforce_suggestions
        add_string_prop args, :acts_as_taggable_on
        add_array_prop args, :disallowed
        add_array_prop args, :delimiters, [","]
        add_array_prop args, :suggestions
        add_string_prop args, :suggestions_max_items
        add_string_prop args, :mode, nil
        add_string_prop args, :fetch_values_from
        add_string_prop args, :fetch_labels
      end

      def field_value
        return fetched_labels if @fetch_labels.present?

        return json_value if acts_as_taggable_on.present?

        value || []
      end

      def json_value
        acts_as_taggable_on_values.map { |value| {value:} }.as_json
      end

      def acts_as_taggable_on_values
        # When record is DB persistent the values are fetched from the DB
        # Else the array values are fetched from the record using the tag_list_on helper
        # values_array examples: ["1", "2"]
        #                        ["example suggestion","example tag"]
        if record.persisted?
          value.map { |item| item.name }
        else
          record.tag_list_on(acts_as_taggable_on)
        end
      end

      def fill_field(record, key, value, params)
        return fill_acts_as_taggable(record, key, value, params) if acts_as_taggable_on.present?

        value = if value.is_a?(String)
          value.split(",")
        else
          value
        end

        record.send(:"#{key}=", apply_update_using(record, key, value, resource))

        record
      end

      def fill_acts_as_taggable(record, key, value, params)
        record.send(act_as_taggable_attribute(key), value)

        record
      end

      def suggestions
        suggestions = Avo::ExecutionContext.new(target: @suggestions, record: record).handle

        # Add field_value when suggestions are array, this is necessary for tagify to apply labels correctly using the tagTextProp option
        if suggestions.is_a?(Array)
          suggestions + field_value
        else
          suggestions
        end
      end

      def disallowed
        Avo::ExecutionContext.new(target: @disallowed, record: record).handle
      end

      def fetch_values_from
        Avo::ExecutionContext.new(target: @fetch_values_from, resource: resource, record: record).handle
      end

      private

      # fetch_labels option should always return an array that match the same values position
      # for the values = [1, 2, 3]
      # and fetch_values return ["One", "Two", "Three"]
      # We'll build (only for forms) [{value: 1, label: "One"}, {value: 2, label: "Two"}, {value: 3, label: "Three"}]
      def fetched_labels
        labels = Avo::ExecutionContext.new(target: @fetch_labels, resource: resource, record: record, values: value).handle

        # Return array of labels (["One", "Two", "Three"]) on display views
        return labels if view.display?

        # Return computed array of hashes for forms
        # [{value: 1, label: "One"}, {value: 2, label: "Two"}, {value: 3, label: "Three"}]
        value.map.with_index { |value, index| {value: value, label: labels[index]} }
      end

      def act_as_taggable_attribute(key)
        "#{key.singularize}_list="
      end
    end
  end
end
