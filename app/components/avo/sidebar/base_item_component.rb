# frozen_string_literal: true

class Avo::Sidebar::BaseItemComponent < ViewComponent::Base
  attr_reader :item

  def initialize(item: nil)
    @item = item
  end

  def items
    item.items
  end
end
