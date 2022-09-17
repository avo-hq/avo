class Avo::Sidebar
  include Avo::Concerns::IsResourceItem
  include Avo::Fields::FieldExtensions::VisibleInDifferentViews

  class_attribute :item_type, default: :sidebar
  delegate :items, :add_item, to: :items_holder

  attr_reader :name
  attr_reader :view
  attr_accessor :items_holder

  def initialize(name: nil, view: nil, **args)
    # Initialize the visibility markers
    super

    @name = name
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

  def empty?
    visible_items.blank?
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
        # Remove the fields that shouldn't be visible in this view
        # eg: has_many fields on edit
        item = nil unless item.visible_on? view
      end

      item
    end
    .compact
  end
end
