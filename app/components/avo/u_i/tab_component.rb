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
          tabindex: @disabled ? -1 : 0
        }
      end

      # Public API - Styling: Classes
      def wrapper_classes
        if @variant == :scope
          base = "tabs__item-wrapper tabs__item-wrapper--scope"
          active_class = @active ? default_active_class : default_inactive_class
          "#{base} #{active_class}"
        else
          "tabs__item-wrapper tabs__item-wrapper--group"
        end
      end

      def classes
        class_list = [
          "tabs__item",
          ((@variant == :scope) ? "tabs__item--scope" : "tabs__item--group"),
          (default_active_class if toggle_classes? && @active),
          (default_inactive_class if toggle_classes? && !@active),
          ("tabs__item--disabled" if @disabled),
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
        "tabs__item--active"
      end

      def default_inactive_class
        "tabs__item--inactive"
      end

      # Private - Styling Helpers
      def icon_classes
        "tabs__item-icon"
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
