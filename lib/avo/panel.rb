class Avo::Panel
  include Avo::Concerns::IsResourceItem
  include Avo::Concerns::VisibleItems
  include Avo::Fields::FieldExtensions::VisibleInDifferentViews

  class_attribute :item_type, default: :panel

  attr_reader :name
  attr_reader :view
  attr_reader :description
  attr_accessor :items_holder

  delegate :items, :add_item, to: :items_holder

  def initialize(name: nil, description: nil, view: nil, **args)
    hide_on :index

    # Initialize the visibility markers
    super

    @name = name
    @view = view
    @description = description
    @items_holder = Avo::ItemsHolder.new

    show_on args[:show_on] if args[:show_on].present?
    hide_on args[:hide_on] if args[:hide_on].present?
    only_on args[:only_on] if args[:only_on].present?
    except_on args[:except_on] if args[:except_on].present?
  end

  def add_item(item)
    @items << item
  end

  def has_items?
    @items.present?
  end
end
