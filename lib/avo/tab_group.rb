class Avo::TabGroup
  include Avo::Concerns::HasFields
  include Avo::Concerns::IsResourceItem

  class_attribute :item_type, default: :tab_group

  attr_reader :view
  attr_accessor :index
  attr_accessor :items_holder

  def initialize(index: 0, view: nil)
    @index = index
    @items_holder = Avo::ItemsHolder.new
    @view = view
  end

  def hydrate(view: nil)
    @view = view

    self
  end

  def visible_items
    items.map do |item|
      item.hydrate view: view
    end
    .select do |item|
      # Remove items hidden in this view
      item.visible_on? view
    end
    .select do |item|
      # Remove empty items
      !item.empty?
    end
  end

  def turbo_frame_id
    "#{Avo::TabGroup.to_s.parameterize} #{index}".parameterize
  end
end
