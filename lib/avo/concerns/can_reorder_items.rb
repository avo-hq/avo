module Avo
  module Concerns
    module CanReorderItems
      extend ActiveSupport::Concern
      def drag_reorder_attributes
        ""
      end

      def drag_reorder_item_attributes
        ""
      end
    end
  end
end
