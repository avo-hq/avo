class Avo::TabGroup
  include Avo::Concerns::HasFields
  include Avo::Concerns::IsResourceItem

  class_attribute :item_type, default: :tab_group

  attr_accessor :index
  attr_accessor :items_holder

  def initialize(index: 0)
    @index = index
    @items_holder = Avo::ItemsHolder.new
  end

  def turbo_frame_id
    "#{Avo::TabGroup.to_s.parameterize} #{index}".parameterize
  end
end
