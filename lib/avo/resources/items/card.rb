class Avo::Resources::Items::Card
  prepend Avo::Concerns::IsResourceItem

  include Avo::Concerns::HasItems
  include Avo::Concerns::HasItemType
  include Avo::Concerns::VisibleItems
  include Avo::Concerns::VisibleInDifferentViews
  include Avo::Concerns::IsVisible

  attr_reader :title
  attr_reader :description

  delegate :items, :add_item, to: :items_holder

  def initialize(title: nil, description: nil, view: nil, **args)
    @title = title
    @view = Avo::ViewInquirer.new view
    @description = description
    @items_holder = Avo::Resources::Items::Holder.new
    @args = args
    @visible = args[:visible]

    post_initialize if respond_to?(:post_initialize)
  end

  class Builder
    include Avo::Concerns::BorrowItemsHolder
    include Avo::Concerns::HasFieldDiscovery

    delegate :heading, to: :items_holder
    delegate :field, to: :items_holder
    delegate :row, to: :items_holder
    delegate :cluster, to: :items_holder
    delegate :items, to: :items_holder
    delegate :sidebar, to: :items_holder

    def initialize(parent:, title: nil, **args)
      @panel = Avo::Resources::Items::Card.new(title: title, **args)
      @items_holder = Avo::Resources::Items::Holder.new(from: self.class, parent: parent)
    end

    # Fetch the tab
    def build
      @panel.items_holder = @items_holder
      @panel
    end
  end
end
