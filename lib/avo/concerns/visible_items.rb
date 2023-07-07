# This concern helps us figure out what items are visible for each tab, panel or sidebar
module Avo
  module Concerns
    module VisibleItems
      extend ActiveSupport::Concern
      def items
        if items_holder.present?
          items_holder.items
        else
          []
        end
      end

      def visible_items
        items
          .map do |item|
            if item.respond_to? :hydrate
              item.hydrate(view: view)
            end

            item
          end
          .map do |item|
            visible(item) ? item : nil
          end
          .compact
      end

      def visible(item)
        return item.visible? unless item.is_field?

        return false if item.respond_to?(:authorized?) && item.resource.present? && !item.authorized?

        item.visible? && item.visible_on?(view)
      end

      def visible?
        any_item_visible = visible_items.any?
        return any_item_visible unless respond_to?(:visible_on?)

        visible_on?(view) && any_item_visible
      end

      def hydrate(view: nil)
        @view = view

        self
      end
    end
  end
end
