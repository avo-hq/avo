module Avo
  module Fields
    class BadgeField < BaseField
      attr_reader :options

      def initialize(id, **args, &block)
        super

        hide_on [:edit, :new]

        default_options = {info: :info, success: :success, danger: :danger, warning: :warning, neutral: :neutral}
        @options = args[:options].present? ? default_options.merge(args[:options]) : default_options

        @color_raw = args[:color]
        @style_raw = args[:style]
        @icon_raw = args[:icon]
        @icon_only_raw = args[:icon_only]
      end

      def options_for_filter
        @options.values.flatten.uniq
      end

      def color
        evaluate_dynamic_value(@color_raw) || badge_color_for_value
      end

      def style
        evaluate_dynamic_value(@style_raw) || "subtle"
      end

      def icon
        evaluate_dynamic_value(@icon_raw)
      end

      def icon_only
        evaluate_dynamic_value(@icon_only_raw) || false
      end

      def badge_color_for_value(value = nil)
        value ||= self.value
        return "secondary" if value.blank?

        value_str = value.to_s.strip
        color_type = find_color_type_for_value(value_str)

        map_color_type_to_badge_color(color_type)
      end

      private

      def find_color_type_for_value(value_str)
        @options.each do |type, values|
          next if values.is_a?(Symbol) && values == type

          values_array = Array.wrap(values).map { |v| v.to_s.strip }
          return type.to_sym if values_array.include?(value_str)
        end

        nil
      end

      def map_color_type_to_badge_color(color_type)
        case color_type
        when :info
          "informative"
        when :success
          "success"
        when :danger
          "error"
        when :warning
          "warning"
        when :neutral
          "secondary"
        else
          "secondary"
        end
      end

      private

      def evaluate_dynamic_value(value)
        return nil if value.nil?
        return value unless value.respond_to?(:call)

        execute_context(value)
      end
    end
  end
end
