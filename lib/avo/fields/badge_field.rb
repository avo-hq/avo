module Avo
  module Fields
    class BadgeField < BaseField
      attr_reader :options

      # Identity mappings: field values like "success" automatically use the success color
      DEFAULT_OPTIONS = {info: :info, success: :success, danger: :danger, warning: :warning, neutral: :neutral}.freeze unless defined?(DEFAULT_OPTIONS)

      def initialize(id, **args, &block)
        super

        hide_on [:edit, :new]

        # Default options provide identity mappings for semantic colors
        # These allow field values like "success" or "info" to automatically map to their color types
        @options = DEFAULT_OPTIONS.merge(args[:options] || {})

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

        find_color_for(normalize(value)) || "neutral"
      end

      private

      def normalize(value)
        value.to_s.strip.downcase
      end

      # Searches through all configured color options to find a match for the field value
      # Returns the color type (e.g., "success", "info") as a string, or nil if no match
      def find_color_for(normalized_value)
        @options.each do |color_type, configured_values|
          return color_type.to_s if normalize_list(configured_values).include?(normalized_value)
        end

        nil
      end

      # Normalizes values for case-insensitive comparison
      # :Done -> ["done"], [:Foo, "Bar"] -> ["foo", "bar"]
      def normalize_list(values)
        Array.wrap(values).map { |v| normalize(v) }
      end
    end
  end
end
