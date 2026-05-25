# frozen_string_literal: true

module Avo
  module Fields
    class CheckboxListField < BaseField
      def initialize(id, **args, &block)
        raise ArgumentError, "Missing required `options:` keyword for checkbox_list field" if !args.key?(:options) || args[:options].nil?

        super

        @options = args[:options]
        @inline_search = args[:inline_search]
      end

      def hydrate(...)
        remove_instance_variable(:@memoized_options) if defined?(@memoized_options)

        super
      end

      def options
        return @memoized_options if defined?(@memoized_options)

        @memoized_options = execute_context(@options)
      end

      def option_id(option)
        option[:id] || option["id"]
      end

      def option_title(option)
        option[:title] || option["title"]
      end

      def option_image_url(option)
        option[:avatar_url] || option["avatar_url"] || option[:image_url] || option["image_url"]
      end

      alias_method :option_avatar_url, :option_image_url

      def option_image_format(option)
        option[:image_format] || option["image_format"]
      end

      def option_image_alt(option)
        option[:image_alt] || option["image_alt"] || option[:avatar_alt] || option["avatar_alt"]
      end

      def option_description(option)
        option[:description] || option["description"]
      end

      def option_hint?(option)
        option[:hint] || option["hint"]
      end

      def selectable_options
        options.reject { |option| option_hint?(option) }
      end

      def inline_search?
        execute_context(@inline_search) == true
      end

      def normalize_id(value)
        value&.to_s
      end

      def to_permitted_param
        ["#{id}": []]
      end

      def fill_field(record, key, value, params)
        super(record, key, Array(value).reject(&:blank?), params)
      end
    end
  end
end
