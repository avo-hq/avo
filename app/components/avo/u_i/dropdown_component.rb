# frozen_string_literal: true

class Avo::UI::DropdownComponent < Avo::BaseComponent
  prop :classes
  prop :data, default: {}.freeze
  prop :wrapper_data, default: {}.freeze
  prop :open, default: false
  prop :dropdown_menu_classes, default: ""
  prop :popover_mode, default: false

  renders_one :trigger
  renders_one :items

  # this is used to trigger the dropdown menu from trigger element
  # data: {action: component.action} => click->dropdown-menu#toggle
  def action
    @action ||= "click->dropdown-menu#toggle"
  end

  def popover_id
    @popover_id ||= "popover-#{SecureRandom.hex(3)}"
  end

  def data
    return {} if items.blank?

    {
      controller: "dropdown-menu",
    }.merge(@wrapper_data)
  end
end
