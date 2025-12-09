# frozen_string_literal: true

module Avo
  module UI
    class TabComponent < Avo::BaseComponent
      include Avo::ApplicationHelper

      # Constants
      VARIANTS = %i[group scope].freeze

      # Color constants
      COLOR_ACTIVE = "#171717"
      COLOR_INACTIVE = "#454545"
      COLOR_BORDER_ACTIVE = "#171717"
      COLOR_BORDER_INACTIVE = "#E7E7E7"
      COLOR_BACKGROUND_ACTIVE = "#F6F6F6"

      # Props
      prop :label
      prop :active, default: false
      prop :icon
      prop :href, default: nil
      prop :id
      prop :disabled, default: false
      prop :aria_controls
      prop :variant, default: :group # :group (no border) or :scope (with border)
      prop :args, kind: :**, default: {}.freeze

      # Lifecycle
      def before_render
        validate_props!
      end

      # Public API - Accessibility & IDs
      def tab_id
        @id || "tab-#{object_id}"
      end

      def tab_aria_controls
        @aria_controls || "#{tab_id}-panel"
      end

      def tab_attributes
        {
          role: "tab",
          id: tab_id,
          "aria-selected": @active,
          "aria-controls": tab_aria_controls,
          "aria-disabled": @disabled,
          tabindex: (@active && !@disabled) ? 0 : -1
        }
      end

      # Public API - Styling: Classes
      def wrapper_classes
        if @variant == :scope
          border_width = @active ? "border-b-2" : "border-b"
          "inline-block py-2 #{border_width} border-solid -mb-[1px]"
        else
          "flex items-center justify-center"
        end
      end

      def classes
        class_list = [
          "inline-flex items-center gap-2 px-3 py-1 rounded-md text-sm font-medium focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500",
          ("disabled:opacity-50 disabled:cursor-not-allowed" if @disabled),
          @args[:class]
        ].compact

        class_list.join(" ")
      end

      # Public API - Styling: Inline Styles
      def wrapper_style
        [border_style, text_color_style].reject(&:blank?).join(" ")
      end

      def background_style
        return "" if @variant == :scope

        @active ? "background-color: #{COLOR_BACKGROUND_ACTIVE};" : ""
      end

      # Public API - Template Helpers
      def render_icon
        return unless @icon.present?

        helpers.svg @icon, class: icon_classes, "aria-hidden": "true"
      end

      private

      # Private - Styling Helpers
      def border_style
        return "" unless @variant == :scope

        color = @active ? COLOR_BORDER_ACTIVE : COLOR_BORDER_INACTIVE
        "border-bottom-color: #{color};"
      end

      def text_color_style
        color = @active ? COLOR_ACTIVE : COLOR_INACTIVE
        "color: #{color};"
      end

      def icon_classes
        "h-4 w-4"
      end

      # Private - Validation
      def validate_props!
        raise ArgumentError, "label is required" if @label.blank?
        raise ArgumentError, "variant must be one of #{VARIANTS.join(", ")}" unless VARIANTS.include?(@variant)
        raise ArgumentError, "active must be true or false" unless [true, false].include?(@active)
        raise ArgumentError, "disabled must be true or false" unless [true, false].include?(@disabled)
        raise ArgumentError, "href must be a String" if @href.present? && !@href.is_a?(String)
      end
    end
  end
end

