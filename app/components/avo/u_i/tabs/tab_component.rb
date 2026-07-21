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
        prop :href, default: "#"
        prop :id, default: -> { "tab-#{object_id}" }
        prop :disabled, default: false
        prop :aria_controls, default: -> { "#{@id}-panel" }
        prop :data, default: {}.freeze
        prop :classes
        prop :title
        prop :badge, default: nil

        private

        # The badge may be a component instance (eager count pill) or a
        # pre-rendered safe string (deferred counter frame); render accordingly.
        def render_badge
          return unless @badge.present?

          @badge.respond_to?(:render_in) ? render(@badge) : @badge
        end
      end
    end
  end
end
