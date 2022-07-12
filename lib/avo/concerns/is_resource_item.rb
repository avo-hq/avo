# This concern helps us figure out what kind of items (field, tool, tab_group, or panel) have been passed to the resource or action.
module Avo
  module Concerns
    module IsResourceItem
      extend ActiveSupport::Concern

      included do
        class_attribute :item_type, default: nil
      end

      def is_field?
        self.class.item_type == :field
      end

      def is_panel?
        self.class.item_type == :panel || self.class.item_type == :main_panel
      end

      def is_main_panel?
        self.class.item_type == :main_panel
      end

      def is_tool?
        self.class.item_type == :tool
      end

      def is_tab?
        self.class.item_type == :tab
      end

      def is_tab_group?
        self.class.item_type == :tab_group
      end
    end
  end
end
