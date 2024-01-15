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
        value.map do |item|
          {
            value: item.name
          }
        end.as_json
      end

      def fill_field(model, key, value, params)
        if acts_as_taggable_on.present?
          model.send(act_as_taggable_attribute(key), value)
        else
          val = if value.is_a?(String)
            value.split(",")
          elsif value.is_a?(Array)
            value
          else
            value
          end
          model.send("#{key}=", val)
        end

        model
      end

      def suggestions
        Avo::ExecutionContext.new(target: @suggestions, record: record).handle
      end

      def disallowed
        Avo::ExecutionContext.new(target: @disallowed, record: record).handle
      end

      def fetch_values_from
        Avo::ExecutionContext.new(target: @fetch_values_from, resource: resource, record: record).handle
      end

      private

      def fetched_labels
        if @fetch_labels.respond_to?(:call)
          Avo::ExecutionContext.new(target: @fetch_labels, resource: resource, record: record).handle
        else
          @fetch_labels
        end
      end

      def act_as_taggable_attribute(key)
        "#{key.singularize}_list="
      end
    end
  end
end
