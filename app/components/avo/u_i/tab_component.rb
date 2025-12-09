# frozen_string_literal: true

module Avo
  module UI
    class TabComponent < Avo::BaseComponent
      include Avo::ApplicationHelper

      # Constants
      VARIANTS = %i[group scope].freeze

      # Props
      prop :label
      prop :active, default: false
      prop :icon
      prop :href, default: nil
      prop :id
      prop :disabled, default: false
      prop :aria_controls
      prop :variant, default: :group # :group (no border) or :scope (with border)
      prop :data, default: {}.freeze
      prop :classes, default: nil

      # Lifecycle
      def before_render
        validate_props!
        assign_default_data
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
          base = "inline-block py-2"
          active_class = @active ? default_active_class : default_inactive_class
          "#{base} avo-tab-wrapper--scope #{active_class}"
        else
          "flex items-center justify-center"
        end
      end

      def classes
        class_list = [
          "avo-tab",
          "inline-flex items-center gap-2 px-3 py-1 text-sm font-medium",
          ((@variant == :scope) ? "rounded-none" : "rounded-md"),
          (default_active_class if toggle_classes? && @active),
          (default_inactive_class if toggle_classes? && !@active),
          ("disabled:opacity-50 disabled:cursor-not-allowed" if @disabled),
          @classes
        ].compact

        class_list.join(" ")
      end

      # Public API - Template Helpers
      def render_icon
        return unless @icon.present?

        helpers.svg @icon, class: icon_classes, "aria-hidden": "true"
      end

      private

      # Private - Data & State Helpers
      def toggle_classes?
        @data[:tab_active_class].present? || @data[:tab_inactive_class].present?
      end

      def assign_default_data
        @data = @data.deep_dup
        @data[:tab_active_class] ||= default_active_class
        @data[:tab_inactive_class] ||= default_inactive_class
      end

      def default_active_class
        "avo-tab--active"
      end

      def default_inactive_class
        "avo-tab--inactive"
      end

      # Private - Styling Helpers
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
        raise ArgumentError, "data must be a Hash" unless @data.is_a?(Hash)
      end
    end
  end
end
