# frozen_string_literal: true

class Avo::Sidebar::BaseItemComponent < ViewComponent::Base
  attr_reader :item

  def initialize(item: nil)
    @item = item
  end

  def items
    item.items
  end

  def key
    result = "avo.#{request.host}.main_menu.#{item.name.to_s.underscore}"

    if item.icon.present?
      result += ".#{item.icon.parameterize.underscore}"
    end

    result
  end

  def collapsable
    item.collapsable
  end

  def collapsed
    item.collapsed
  end
end
