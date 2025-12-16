module Avo
  module Fields
    class BadgeField < BaseField
      attr_reader :options

      def initialize(id, **args, &block)
        super(id, **args, &block)

        hide_on [:edit, :new]

        default_options = {info: :info, success: :success, danger: :danger, warning: :warning, neutral: :neutral}
        @options = args[:options].present? ? default_options.merge(args[:options]) : default_options
      end

      def options_for_filter
        @options.values.flatten.uniq
      end

      # Maps the field value to a BadgeComponent color based on options configuration
      # Maps old BadgeViewerComponent color types (info, success, danger, warning, neutral)
      # to new BadgeComponent colors (informative, success, error, warning, secondary)
      def badge_color_for_value(value = nil)
        value ||= self.value
        return "secondary" if value.blank?

        # Find which color type this value maps to
        color_type = :info # default

        @options.invert.each do |values, type|
          if [values].flatten.map { |v| v.to_s }.include?(value.to_s)
            color_type = type.to_sym
            break
          end
        end

        # Map old color names to new BadgeComponent color names
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
    end
  end
end
