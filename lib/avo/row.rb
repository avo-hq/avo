class Avo::Row
  include Avo::Concerns::IsResourceItem
  include Avo::Concerns::VisibleItems

  class_attribute :item_type, default: :row

  attr_reader :view
  attr_accessor :items_holder

  delegate :items, :add_item, to: :items_holder

  def initialize(view: nil)
    @view = view
    @items_holder = Avo::ItemsHolder.new
  end

  def has_items?
    @items.present?
  end
end