module Avo
  module Concerns
    module CanReplaceItems
      extend ActiveSupport::Concern

      included do
        class_attribute :temporary_items
      end

      class_methods do
        def with_temporary_items(&block)
          # back-up the previous items
          self.temporary_items = block
        end

        def restore_items_from_backup
          self.temporary_items = nil
        end

        def with_new_items(&block)
          self.items_holder = Avo::Resources::Items::Holder.new

          instance_eval(&block)
        end
      end

      def with_new_items(&block)
        self.class.with_new_items(&block)
      end
    end
  end
end
