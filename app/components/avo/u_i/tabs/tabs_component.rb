# frozen_string_literal: true

module Avo
  module UI
    module Tabs
      class TabsComponent < Avo::BaseComponent
        prop :variant, default: :scope
        prop :aria_label, default: "Tabs navigation"
        prop :id, default: -> { "tabs-#{object_id}" }
      end
    end
  end
end
