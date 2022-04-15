module Avo
  module Fields
    class TagsField < BaseField
      attr_reader :acts_as_taggable_on
      attr_reader :close_on_select
      attr_reader :delimiters
      attr_reader :enforce_suggestions

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @suggestions = args[:suggestions].present? ? args[:suggestions] : []
        @acts_as_taggable_on = args[:acts_as_taggable_on].present? ? args[:acts_as_taggable_on] : nil
        @enforce_suggestions = args[:enforce_suggestions].present? ? args[:enforce_suggestions] : false
        @delimiters = args[:delimiters].present? ? args[:delimiters] : [","]
        @close_on_select = args[:close_on_select] == true
      end

      def json_value
        value.map do |item|
          {
            value: item.name
          }
        end.as_json
      end

      def fill_field(model, key, value, params)
        # parsed_value(value)

        # puts ['->', model, key, value, params].inspect
        model.send(act_as_taggable_attribute(key), parsed_value(value))
        # puts ["->", "#{key.singularize}_list=", model.tag_list, JSON.parse(value).pluck(:value)].inspect

        model
      end

      def suggestions
        return @suggestions if @suggestions.is_a? Array

        if @suggestions.respond_to? :call
          return Avo::Hosts::RecordHost.new(block: @suggestions, record: model).handle
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
