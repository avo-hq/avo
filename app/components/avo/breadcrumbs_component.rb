# frozen_string_literal: true

class Avo::BreadcrumbsComponent < Avo::BaseComponent
  prop :items, default: -> { [] }
  prop :separator, default: -> { ">" }
  prop :truncate, default: -> { false }
  prop :max_items, default: -> { 5 }

  private

  def truncate_items
    return @items if @items.length <= @max_items

    # Show first item, ellipsis, and last (max_items - 2) items

    first_item = @items.first
    last_items = @items.last(@max_items - 2)
    ellipsis_item = {text: "...", current: false}

    [first_item, ellipsis_item, *last_items]
  end
end
