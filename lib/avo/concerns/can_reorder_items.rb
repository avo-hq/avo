module Avo
  module Concerns
    module CanReorderItems
      extend ActiveSupport::Concern

      included do
        if defined? Avo::Pro::Concerns::CanReorderItems
          include Avo::Pro::Concerns::CanReorderItems
        end
      end

      def can_reorder?
        false
      end

      def can_dnd_reorder?
        false
      end

      def drag_reorder_attributes
        ''
      end

      def drag_reorder_item_attributes
        ''
      end
    end
  end
end
