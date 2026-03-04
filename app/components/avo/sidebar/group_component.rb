# frozen_string_literal: true

class Avo::Sidebar::GroupComponent < Avo::Sidebar::BaseItemComponent
  def icon
    item.icon if item.icon.present?
  end

  # True if any visible item in the group has an icon (so all items should reserve icon space for alignment).
  def group_has_any_icon?
    @items.any? { |child| child.try(:icon).present? }
  end
end
