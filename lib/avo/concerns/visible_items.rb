# This concern helps us figure out what items are visible for each tab, panel or sidebar
module Avo
    module Concerns
      module VisibleItems
        extend ActiveSupport::Concern
  
        def items
          if self.items_holder.present?
            self.items_holder.items
          else
            []
          end
        end
    
        def visible_items
          items.map do |item|
            visible(item) ? item : nil
          end
          .compact
        end
    
        def visible(item)
          if item.is_field?
            item.visible? && item.visible_on?(view)
          else
            item.visible?
          end
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
  