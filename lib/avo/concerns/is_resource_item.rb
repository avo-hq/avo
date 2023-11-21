# This concern helps us figure out what kind of items (field, tool, tab_group, or panel) have been passed to the resource or action.
module Avo
  module Concerns
    module IsResourceItem
      include Avo::Concerns::Hydration

      # These attributes are required to be hydrated in order to properly find the visible_items
      attr_accessor :resource
      attr_accessor :view

      # Returns the final state of if an item is visible or not
      # For items that have children it checks to see if it contains any visible children.
      def visible?
        # For items that may contains other items like tabs and panels we should also check
        # if any on their children have visible items.
        if self.class.ancestors.include?(Avo::Concerns::HasItems)
          return false unless visible_items.any?
        end

        super
      end
    end
  end
end
