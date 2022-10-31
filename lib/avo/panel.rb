class Avo::Panel
  include Avo::Concerns::IsResourceItem
  include Avo::Concerns::VisibleItems

  class_attribute :item_type, default: :panel

  attr_reader :name
  attr_reader :view
  attr_reader :description
  attr_accessor :items_holder

  delegate :items, :add_item, to: :items_holder

  def initialize(name: nil, description: nil, view: nil)
    @name = name
    @view = view
    @description = description
    @items_holder = Avo::ItemsHolder.new
  end

  def add_item(item)
    @items << item
  end

  def has_items?
    @items.present?
  end
end
