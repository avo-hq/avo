# frozen_string_literal: true

class Avo::Sidebar::GroupComponent < Avo::Sidebar::BaseItemComponent
  def icon
    item.icon if item.icon.present?
  end

  # True if any visible item in the group has an icon (so all items should reserve icon space for alignment).
  def group_has_any_icon?
    @items.any? { |child| effective_icon_for(child).present? }
  end

  private

  # Check if menu item has an icon. Must match LinkComponent.effective_icon logic so
  # group_has_any_icon? is true when any item would display an icon (including label-based fallbacks).
  def effective_icon_for(menu_item)
    icon = nil
    label = nil

    case menu_item
    when Avo::Menu::Link
      icon = menu_item.icon
      label = menu_item.name
    when Avo::Menu::Resource
      icon = menu_item.icon.presence || menu_item.parsed_resource&.icon
      label = menu_item.try(:navigation_label) || menu_item.try(:name).to_s
    when Avo::Menu::Dashboard, Avo::Menu::Board, Avo::Menu::Page
      icon = menu_item.icon
      label = menu_item.try(:navigation_label).to_s
    else
      icon = menu_item.try(:icon)
      label = menu_item.try(:name).to_s
    end

    Avo::Sidebar::LinkComponent.effective_icon(icon: icon, label: label)
  end
end
