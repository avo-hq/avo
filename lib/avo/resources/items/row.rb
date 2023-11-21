class Avo::Resources::Items::Row
  include Avo::Concerns::IsResourceItem
  include Avo::Concerns::HasItems
  include Avo::Concerns::HasItemType
  include Avo::Concerns::VisibleItems
  include Avo::Concerns::Hydration

  class_attribute :item_type, default: :row

  attr_reader :view
  attr_accessor :items_holder

  delegate :items, :add_item, to: :items_holder

  def initialize(view: nil)
    @view = Avo::ViewInquirer.new view
    @items_holder = Avo::Resources::Items::Holder.new
  end

  def has_items?
    @items.present?
  end

  class Builder
    include Avo::Concerns::BorrowItemsHolder

    delegate :field, to: :items_holder
    delegate :tool, to: :items_holder
    delegate :items, to: :items_holder

    def initialize(parent:, **args)
      @row = Avo::Resources::Items::Row.new(**args)
      @items_holder = Avo::Resources::Items::Holder.new(parent: @parent)
    end

    # Fetch the tab
    def build
      @row.items_holder = @items_holder
      @row
    end
  end
end
