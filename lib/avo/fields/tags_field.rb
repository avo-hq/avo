module Avo
  module Fields
    class TagsField < Avo::Fields::BaseField

      class_attribute :supported_options, default: {}
      Avo::Fields::COMMON_OPTIONS.each do |common_option, hash|
        supports common_option, hash
      end

      supports :close_on_select
      supports :enforce_suggestions
      supports :acts_as_taggable_on
      supports :disallowed
      supports :delimiters, default: [","]
      supports :suggestions
      supports :suggestions_max_items
      supports :mode, default: nil
      supports :fetch_values_from

      def select_mode?
        @mode&.to_sym == :select
      end

      def field_value
        @field_value ||= if acts_as_taggable_on.present?
          acts_as_taggable_on_values.map { |value| {value:} }.as_json
        else
          # Wrap the value on Array to ensure select mode compatibility
          Array.wrap(value) || []
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

        value = if value.is_a?(String) && !select_mode?
          value.split(delimiters[0])
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

        (suggestions + field_value).uniq.to_json
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
