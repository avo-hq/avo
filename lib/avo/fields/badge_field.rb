module Avo
  module Fields
    class BadgeField < BaseField
      attr_reader :options

      def initialize(id, **args, &block)
        super

        hide_on [:edit, :new]

        @options = args[:options] || {}
        @color = args[:color]
        @style = args[:style]
        @icon = args[:icon]
      end

      def options_for_filter
        @options.values.flatten.uniq
      end

      def color
        # Priority 1: Use explicit color if provided (via proc/lambda or direct value)
        # Priority 2: Fall back to automatic color detection based on field value and options mapping
        execute_context(@color) || badge_color_for_value
      end

      def style
        execute_context(@style) || "subtle"
      end

      def icon
        execute_context(@icon)
      end

      # Maps field value to a color based on @options configuration
      # Example: "Done" -> "success" if options = { success: [:done, :complete] }
      def badge_color_for_value
        return "neutral" if value.blank?

        @options.find { |_, configured_values|
          Array(configured_values).map { |v| v.to_s }.include?(value.to_s)
        }&.first&.to_s || "neutral"
      end
    end
  end
end
