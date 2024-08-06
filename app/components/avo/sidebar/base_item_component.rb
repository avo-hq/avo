# frozen_string_literal: true

class Avo::Sidebar::BaseItemComponent < Avo::BaseComponent
  attr_reader :item, :items
  delegate :collapsable, :collapsed, to: :@item

  def initialize(item: nil)
    @item = item
    @items = @item.items.select(&:visible?)
  end

  def render?
    items.any?
  end

  def key
    result = "avo.#{request.host}.main_menu.#{@item.name.to_s.underscore}"

    if @item.icon.present?
      result += ".#{@item.icon.parameterize.underscore}"
    end

    result
  end

  def section_collapse_data_animation
    {
      transition_enter: "transition ease-out duration-100",
      transition_enter_start: "transform opacity-0 -translate-y-4",
      transition_enter_end: "transform opacity-100 translate-y-0",
      transition_leave: "transition ease-in duration-75",
      transition_leave_start: "transform opacity-100 translate-y-0",
      transition_leave_end: "transform opacity-0 -translate-y-4",
    }
  end
end
