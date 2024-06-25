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

      # Always output an array of objects that follow this structure
      # [{label: "hello world", value: 123}]
      def field_value
        return normalized_value if suggestions.blank?

        return normalized_value
      end

      def normalized_value
        puts ["value->", value].inspect
        # TODO:
        return fetched_labels if @fetch_labels.present?

        return acts_as_taggable_value if acts_as_taggable_on.present?

        return hash_value if is_hash_like?

        return make_hash value if value.present?

        []
      end

      def make_hash(value)
        value.map do |item|
          {
            value: item,
            label: item,
          }
        end
      end

      def hash_value
        value
      end

      def fill_field(model, key, value, params)
        return fill_acts_as_taggable(model, key, value, params) if acts_as_taggable_on.present?

        val = if value.is_a?(String)
          value.split(",")
        elsif value.is_a?(Array)
          value
        else
          value
        end
        model.send(:"#{key}=", val)

        model
      end

      def fill_acts_as_taggable(model, key, value, params)
        model.send(act_as_taggable_attribute(key), value)

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

      def suggestions_by_value
        return {} unless suggestions_are_a_hash?

        suggestions.map do |suggestion|
          [suggestion[:value].to_s, suggestion]
        end.to_h
      end

      private

      def acts_as_taggable_value
        value.map do |item|
          {
            value: item.name,
            label: item.name
          }
        end
      end

      def def_item_is_a_hash?(value)
        item.present? && item.is_a?(Hash) && item.key?(:label) && item.key?(:value)
      end

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

      def suggestions_are_a_hash?
        return false if suggestions.blank?

        def_item_is_a_hash?(suggestions.first)
      end
    end
  end
end
