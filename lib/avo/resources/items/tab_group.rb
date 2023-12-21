class Avo::Resources::Items::TabGroup
  prepend Avo::Concerns::IsResourceItem

  include Avo::Concerns::HasItems
  include Avo::Concerns::HasItemType
  include Avo::Concerns::IsVisible
  include Avo::Concerns::VisibleInDifferentViews

  attr_accessor :index
  attr_accessor :style
  attr_accessor :name

  def initialize(index: 0, view: nil, style: nil, id: nil, name: nil, **args)
    @index = index
    @items_holder = Avo::Resources::Items::Holder.new
    @view = Avo::ViewInquirer.new view
    @style = style
    @id = id
    @name = name
    @args = args

    post_initialize if respond_to?(:post_initialize)
  end

  # The user might assign an id to a group.
  # If not, we'll use the name.
  # If not, we'll use the index
  def id
    return @id if @id.present?
    return @name.parameterize if @name.present?

    index
  end
  alias_method :to_param, :id

  def turbo_frame_id
    "#{Avo::Resources::Items::TabGroup.to_s.parameterize} #{index}".parameterize
  end

  def group_param
    "tab-group_#{id}"
  end

  class Builder
    include Avo::Concerns::BorrowItemsHolder

    delegate :tab, to: :items_holder

    def field(field_name, **args, &block)
      parsed = Avo::Dsl::FieldParser.new(id: field_name, order_index: @items_index, **args, &block).parse
      field_instance = parsed.instance

      name = field_instance.name
      tab = Avo::Resources::Items::Tab.new name: name

      if field_instance.has_own_panel?
        tab.items_holder.add_item parsed.instance
      else
        # If the field is not in a panel, create one and add it
        panel = Avo::Resources::Items::Panel.new name: name
        panel.items_holder.add_item parsed.instance
        # Add that panel to the items_holder
        tab.items_holder.add_item panel
      end

      @items_holder.tabs tab
    end

    def initialize(name:, id:, parent:, style: nil)
      @group = Avo::Resources::Items::TabGroup.new(name: name, id: id, style: style)
      @items_holder = Avo::Resources::Items::Holder.new(parent: parent, from: self)
    end

    # Fetch the tab
    def build
      @group.items_holder = @items_holder
      @group
    end
  end
end
