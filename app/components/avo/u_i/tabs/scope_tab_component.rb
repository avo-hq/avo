# frozen_string_literal: true

module Avo
  module UI
    module Tabs
      class ScopeTabComponent < BaseTabComponent
        def wrapper_classes
          base = "tabs__item-wrapper tabs__item-wrapper--scope"
          active_class = @active ? ACTIVE_CLASS : nil
          [base, active_class].compact.join(" ")
        end

        private

        def variant
          :scope
        end
      end
    end
  end
end
