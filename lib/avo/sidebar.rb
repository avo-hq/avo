class Avo::Sidebar
  include Avo::Concerns::IsResourceItem
  include Avo::Concerns::VisibleItems
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

  def empty?
    visible_items.blank?
  end
end
