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

        @format_using ||= args[:fetch_labels]

        unless Rails.env.production?
          if args[:fetch_labels].present?
            puts "[Avo DEPRECATION WARNING]: The `fetch_labels` field configuration option is no longer supported and will be removed in future versions. Please discontinue its use and solely utilize the `format_using` instead."
          end
        end
      end

      def field_value
        @field_value ||= if acts_as_taggable_on.present?
          acts_as_taggable_on_values.map { |value| {value:} }.as_json
        else
          value || []
        end
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
          value.split Regexp.union(delimiters)
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

      def whitelist_items
        return suggestions.to_json if enforce_suggestions

        (suggestions + field_value).to_json
      end

      def suggestions
        @fetched_suggestions ||= Avo::ExecutionContext.new(target: @suggestions, record: record).handle
      end

      def disallowed
        Avo::ExecutionContext.new(target: @disallowed, record: record).handle
      end

      def fetch_values_from
        Avo::ExecutionContext.new(target: @fetch_values_from, resource: resource, record: record).handle
      end

      private

      def act_as_taggable_attribute(key)
        "#{key.singularize}_list="
      end
    end
  end
end
