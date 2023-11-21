module Avo
  module Concerns
    module BorrowItemsHolder
      extend ActiveSupport::Concern

      included do
        attr_reader :items_holder
      end

      class_methods do
        def parse_block(parent:, **args, &block)
          # item = Avo::Resources::Items:: ...
          item = new(parent: parent, **args)

          # Borrow the current items holder to the parent (parent = Action || Resource, etc.)
          # Save parent's items holder to restore it after the block is parsed
          # This is useful when you execute parent's methods like `some_fields_method` inside some DSL block.
          # When you do that, Docile will not find the method in the current object (item), but in the parent.
          # So we need to temporarily replace the parent's items holder with the current one because the parent's methods
          # will be executed in the parent's context.
          # For more context: https://github.com/ms-ati/docile/issues/107
          parent_item_holder = parent.items_holder
          parent.items_holder = item.items_holder

          dsl_evaluation = Docile.dsl_eval(item, &block).build

          # Restore the parent's items holder
          parent.items_holder = parent_item_holder

          dsl_evaluation
        end
      end
    end
  end
end
