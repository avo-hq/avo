module Avo
  module Fields
    class TagsField < BaseField
      attr_reader :acts_as_taggable_on
      attr_reader :close_on_select
      attr_reader :delimiters
      attr_reader :enforce_suggestions

      def initialize(id, **args, &block)
        super(id, **args, &block)

        add_boolean_prop args, :close_on_select
        add_boolean_prop args, :enforce_suggestions
        add_string_prop args, :acts_as_taggable_on
        add_array_prop args, :disallowed
        add_array_prop args, :delimiters, [","]
        add_array_prop args, :suggestions
      end

      def field_value
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
          model.send(act_as_taggable_attribute(key), parsed_value(value))
        else
          model.send("#{key}=", parsed_value(value))
        end

        model
      end

      def suggestions
        return @suggestions if @suggestions.is_a? Array

        if @suggestions.respond_to? :call
          return Avo::Hosts::RecordHost.new(block: @suggestions, record: model).handle
        end

        []
      end

      def disallowed
        return @disallowed if @disallowed.is_a? Array

        if @disallowed.respond_to? :call
          return Avo::Hosts::RecordHost.new(block: @disallowed, record: model).handle
        end

        []
      end

      private

      def act_as_taggable_attribute(key)
        "#{key.singularize}_list="
      end

      def parsed_value(value)
        JSON.parse(value).pluck("value")
      rescue
        []
      end

      private

      def parse_suggestions_from_args(args)
      end
    end
  end
end
