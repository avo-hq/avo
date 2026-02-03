# frozen_string_literal: true

class Avo::UI::DropdownComponent < Avo::BaseComponent
  prop :classes
  prop :data, default: {}.freeze

  renders_one :trigger
  renders_one :items

  # this is used to trigger the dropdown menu from trigger element
  # data: {action: component.action} => click->dropdown-menu#toggle
  def action
    @action ||= "click->dropdown-menu#toggle"
  end

  def data
    return {} if items.blank?

    {
      controller: "dropdown-menu"
    }
  end
end
