module Avo
  module Concerns
    module CanReplaceFields
      extend ActiveSupport::Concern

      included do
        class_attribute :backup_items_holder
      end

      class_methods do
        def with_temporary_items(&block)
          # back-up the previous items
          self.backup_items_holder = items_holder

          self.items_holder = Avo::ItemsHolder.new

          instance_eval(&block)
        end

        def restore_items_from_backup
          self.items_holder = backup_items_holder if backup_items_holder.present?
        end

        def with_new_items(&block)
          self.items_holder = Avo::ItemsHolder.new

          instance_eval(&block)
        end
      end

      def with_new_items(&block)
        self.class.with_new_items(&block)
      end
    end
  end
end
