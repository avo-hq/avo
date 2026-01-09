# frozen_string_literal: true

module Avo
  module UI
    module Tabs
      class TabComponent < Avo::BaseComponent
        include Avo::ApplicationHelper

        ACTIVE_CLASS = "tabs__item--active"

        prop :label
        prop :variant, default: :scope
        prop :active, default: false
        prop :icon
        prop :href, default: nil
        prop :id
        prop :disabled, default: false
        prop :aria_controls
        prop :data, default: {}.freeze
        prop :classes, default: nil
        prop :title, default: nil

        def before_render
          @data = @data.deep_dup
          @data[:tab_active_class] ||= ACTIVE_CLASS
        end

        def link?
          @href.present? && @href != "#" && !@disabled
        end

        def shared_attributes
          {
            class: element_classes,
            data: @data,
            title: @title,
            **tab_attributes.except(:"aria-disabled")
          }
        end

        def button_attributes
          shared_attributes.merge(
            type: "button",
            disabled: @disabled,
            "aria-disabled": @disabled
          )
        end

        def tab_content
          safe_join([render_icon, label_span].compact)
        end

        def wrapper_classes
          base = "tabs__item-wrapper tabs__item-wrapper--#{@variant}"
          # Scope variant needs active class on wrapper for underline CSS
          active_class = (scope? && @active) ? ACTIVE_CLASS : nil
          [base, active_class].compact.join(" ")
        end

        private

        def render_icon
          return unless @icon.present?

          helpers.svg @icon, class: "tabs__item-icon", "aria-hidden": "true"
        end

        def scope?
          @variant == :scope
        end

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

        def element_classes
          [
            "tabs__item",
            "tabs__item--#{@variant}",
            (ACTIVE_CLASS if @active),
            ("tabs__item--disabled" if @disabled),
            @classes
          ].compact.join(" ")
        end

        def label_span
          content_tag(:span, @label, class: "tabs__item-label")
        end
      end
    end
  end
end
