# This concern helps us figure out what kind of items (field, tool, tab_group, or panel) have been passed to the resource or action.
module Avo
  module Concerns
    module HasItemType
      def is_field?
        self.class.ancestors.include?(Avo::Fields::BaseField)
      end

      def is_heading?
        self.class.ancestors.include?(Avo::Fields::HeadingField)
      end

      def is_panel?
        self.class.ancestors.include?(Avo::Resources::Items::Panel)
      end

      def is_card?
        self.class.ancestors.include?(Avo::Resources::Items::Card)
      end

      def is_header?
        self.class.ancestors.include?(Avo::Resources::Items::Header)
      end

      def is_tool?
        self.class.ancestors.include?(Avo::BaseResourceTool)
      end

      def is_tab?
        self.class.ancestors.include?(Avo::Resources::Items::Tab)
      end

      def is_tab_group?
        self.class.ancestors.include?(Avo::Resources::Items::TabGroup)
      end

      def is_sidebar?
        self.class.ancestors.include?(Avo::Resources::Items::Sidebar)
      end

      def is_row?
        self.class.respond_to?(:item_type) && self.class.item_type == :row
      end

      def is_collaboration?
        self.class.ancestors.include?(Avo::Resources::Items::Collaboration)
      end
    end
  end
end
