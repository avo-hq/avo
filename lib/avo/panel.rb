class Avo::Panel
  include Avo::Concerns::IsResourceItem

  class_attribute :item_type, default: :panel

  attr_reader :name
  attr_reader :description
  attr_accessor :items_holder

  delegate :items, :add_item, to: :items_holder

  def initialize(name: nil, description: nil)
    @name = name
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
