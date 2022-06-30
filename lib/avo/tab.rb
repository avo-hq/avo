class Avo::Tab
  include Avo::Concerns::IsResourceItem

  class_attribute :item_type, default: :tab
  delegate :items, :add_item, to: :items_holder

  attr_reader :name
  attr_accessor :items_holder
  attr_accessor :description

  def initialize(name: nil, description: nil)
    @name = name
    @description = description
    @items_holder = Avo::ItemsHolder.new
  end

  def turbo_frame_id(parent: nil)
    id = "#{Avo::Tab.to_s.parameterize} #{name}".parameterize

    return id if parent.nil?


    "#{parent.turbo_frame_id} #{id}".parameterize
  end
end
