class Avo::Tab
  include Avo::Concerns::IsResourceItem
  include Avo::Fields::FieldExtensions::VisibleInDifferentViews

  class_attribute :item_type, default: :tab
  delegate :items, :add_item, to: :items_holder

  attr_reader :name
  attr_reader :view
  attr_accessor :description
  attr_accessor :items_holder
  attr_accessor :holds_one_field

  def initialize(name: nil, description: nil, view: nil, holds_one_field: false, **args)
    # Initialize the visibility markers
    super

    @name = name
    @description = description
    @holds_one_field = holds_one_field
    @items_holder = Avo::ItemsHolder.new
    @view = view

    show_on args[:show_on] if args[:show_on].present?
    hide_on args[:hide_on] if args[:hide_on].present?
    only_on args[:only_on] if args[:only_on].present?
    except_on args[:except_on] if args[:except_on].present?
  end

  def hydrate(view: nil)
    @view = view

    self
  end

  def turbo_frame_id(parent: nil)
    id = "#{Avo::Tab.to_s.parameterize} #{name}".parameterize

    return id if parent.nil?

    "#{parent.turbo_frame_id} #{id}".parameterize
  end

  def empty?
    visible_items.blank?
  end

  # Checks for visibility on itself or on theone field it holds
  def visible_on?(view)
    if holds_one_field
      super(view) && items.first.visible_on?(view)
    else
      super(view)
    end
  end

  def items
    if self.items_holder.present?
      self.items_holder.items
    else
      []
    end
  end

  def visible_items
    items.map do |item|
      if item.is_field?
        visible = item.visible_on?(view)
        # Remove the fields that shouldn't be visible in this view
        # eg: has_many fields on edit
        item = nil unless visible
      end

      item
    end
    .compact
  end
end
