module Avo
  module Fields
    class BadgeField < BaseField
      attr_reader :options

      def initialize(id, **args, &block)
        hide_on :forms

        super

        @options = args[:options] || {}
        @style = args[:style]
        @icon = args[:icon]
      end

      # Action modals render every declared field, so a badge that was not put on the forms has to stay display-only there.
      def component_for_view(view = :index)
        return Avo::BlankFieldComponent if view.to_s.in?(%w[new create edit update]) && !show_on_new && !show_on_edit

        super
      end

      def options_for_filter
        @options.values.flatten.uniq
      end

      # Maps field value to a color based on @options configuration
      # Example: "Done" -> "success" if options = { success: [:done, :complete] }
      def color
        return "neutral" if value.blank?

        values = @options.find do |_, configured_values|
          Array.wrap(configured_values).map { |v| v.to_s }.include?(value.to_s)
        end
        values&.first&.to_s || "neutral"
      end

      def style
        execute_context(@style) || "subtle"
      end

      def icon
        execute_context(@icon)
      end
    end
  end
end
