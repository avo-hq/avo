# frozen_string_literal: true

module Avo
  module UI
    module Tabs
      class TabsComponent < Avo::BaseComponent
        prop :variant, default: :scope
        prop :aria_label
        prop :id

        def classes
          "tabs tabs--#{@variant}"
        end

        def tablist_id
          @id || "tabs-#{object_id}"
        end

        def tablist_aria_label
          @aria_label || "Tabs navigation"
        end
      end
    end
  end
end
