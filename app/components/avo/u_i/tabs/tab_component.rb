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
        prop :href
        prop :id, default: -> { "tab-#{object_id}" }
        prop :disabled, default: false
        prop :aria_controls, default: -> { "#{@id}-panel" }
        prop :data, default: {}.freeze
        prop :classes
        prop :title

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

        private

        def scope?
          @variant == :scope
        end

        def tab_attributes
          {
            role: "tab",
            id: @id,
            "aria-selected": @active,
            "aria-controls": @aria_controls,
            "aria-disabled": @disabled,
            tabindex: @disabled ? -1 : 0
          }
        end

        def element_classes
          class_names(
            @classes,
            "tabs__item",
            "tabs__item--group": @variant == :group,
            "tabs__item--disabled": @disabled,
            "#{ACTIVE_CLASS}": @active
          )
        end
      end
    end
  end
end
