# frozen_string_literal: true

class Avo::UI::DropdownComponent < Avo::BaseComponent
  prop :classes
  prop :data, default: {}.freeze
  prop :wrapper_data, default: {}.freeze
  prop :open, default: false
  prop :dropdown_menu_classes, default: ""
  prop :popover_mode, default: false
  # Renders a filter input above the items that narrows them as the user types
  # (client-side, over the rendered items). Popover mode only.
  prop :searchable, default: false
  prop :search_placeholder

  renders_one :trigger
  renders_one :items
  # A row pinned under the list — outside the scrollable group and the inline
  # search's filter scope, so it stays visible. Popover mode only.
  renders_one :footer

  # this is used to trigger the dropdown menu from trigger element
  # data: {action: component.action} => click->dropdown-menu#toggle
  def action
    @action ||= "click->dropdown-menu#toggle"
  end

  def popover_id
    @popover_id ||= "popover-#{SecureRandom.hex(3)}"
  end

  def search_placeholder
    @search_placeholder || I18n.t("avo.search.placeholder", default: "Search")
  end

  def data
    return {} if items.blank?

    {
      controller: "dropdown-menu",
    }.merge(@wrapper_data)
  end
end
