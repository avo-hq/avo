module Avo
  module Fields
    class TagsField < BaseField
      attr_reader :acts_as_taggable_on
      attr_reader :close_on_select
      attr_reader :delimiters
      attr_reader :enforce_suggestions

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @acts_as_taggable_on = args[:acts_as_taggable_on].present? ? args[:acts_as_taggable_on] : nil
        @blacklist = args[:blacklist].present? ? args[:blacklist] : []
        @close_on_select = args[:close_on_select] == true
        @delimiters = args[:delimiters].present? ? args[:delimiters] : [","]
        @enforce_suggestions = args[:enforce_suggestions].present? ? args[:enforce_suggestions] : false
        @suggestions = args[:suggestions].present? ? args[:suggestions] : []
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

      def blacklist
        return @blacklist if @blacklist.is_a? Array

        if @blacklist.respond_to? :call
          return Avo::Hosts::RecordHost.new(block: @blacklist, record: model).handle
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
