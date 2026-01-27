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
      end
    end
  end
end
