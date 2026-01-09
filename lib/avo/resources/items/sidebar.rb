class Avo::Resources::Items::Sidebar
  prepend Avo::Concerns::IsResourceItem

  include Avo::Concerns::HasFieldDiscovery
  include Avo::Concerns::HasItems
  include Avo::Concerns::HasItemType
  include Avo::Concerns::IsVisible
  include Avo::Concerns::VisibleInDifferentViews

  delegate :items, :add_item, to: :items_holder

  attr_reader :title

  def initialize(title: nil, view: nil, **args)
    @title = title
    @items_holder = Avo::Resources::Items::Holder.new
    @view = Avo::ViewInquirer.new view
    @args = args

    post_initialize if respond_to?(:post_initialize)
  end

  class Builder
    include Avo::Concerns::BorrowItemsHolder
    include Avo::Concerns::HasFieldDiscovery

    delegate :field, to: :items_holder
    delegate :tool, to: :items_holder
    delegate :items, to: :items_holder
    delegate :heading, to: :items_holder
    delegate :card, to: :items_holder

    def initialize(parent:, **args)
      @sidebar = Avo::Resources::Items::Sidebar.new(**args)
      @items_holder = Avo::Resources::Items::Holder.new(parent: parent)
    end

    # Fetch the sidebar
    def build
      @sidebar.items_holder = @items_holder
      @sidebar
    end
  end
end
