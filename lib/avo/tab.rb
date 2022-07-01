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

  def items(view: :show)
    if self.items_holder.present?
      self.items_holder
        .items
        # Check all the fields
        .map do |item|
          if item.is_field?
            visible = item.visible_on?(view)
            # Remove the fields that shouldn't be visible in this view
            # eg: has_many fields on edit
            item = nil unless visible
          end

          item
        end
        .compact
    else
      []
    end
  end
end
