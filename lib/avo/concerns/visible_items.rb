# This concern helps us figure out what items are visible for each tab, panel or sidebar
module Avo
  module Concerns
    module VisibleItems
      extend ActiveSupport::Concern

      included do
        include Avo::Concerns::Hydration
      end

      def visible?
        if respond_to?(:visible_on?)
          visible_on?(view) && visible_items.any?
        else
          visible_items.any?
        end
      end
    end
  end
end
