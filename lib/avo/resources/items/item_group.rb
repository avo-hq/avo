class Avo::Resources::Items::ItemGroup
  prepend Avo::Concerns::IsResourceItem

  include Avo::Concerns::HasItems
  include Avo::Concerns::HasItemType
  include Avo::Concerns::VisibleItems
  include Avo::Concerns::VisibleInDifferentViews

  attr_reader :name
  attr_reader :description

  delegate :items, :add_item, to: :items_holder

  def initialize(name: nil, description: nil, view: nil, **args)
    @name = name
    @view = Avo::ViewInquirer.new view
    @description = description
    @items_holder = Avo::Resources::Items::Holder.new
    @args = args

    post_initialize if respond_to?(:post_initialize)
  end

  class Builder
    include Avo::Concerns::BorrowItemsHolder

    delegate :heading, to: :items_holder
    delegate :field, to: :items_holder
    delegate :row, to: :items_holder
    delegate :items, to: :items_holder
    delegate :sidebar, to: :items_holder

    def initialize(parent:, name: nil, **args)
      @panel = Avo::Resources::Items::Panel.new(name: name, **args)
      @items_holder = Avo::Resources::Items::Holder.new(from: self.class, parent: parent)
    end

    # Fetch the tab
    def build
      @panel.items_holder = @items_holder
      @panel
    end
  end
end
