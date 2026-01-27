# frozen_string_literal: true

class Avo::UI::DropdownComponent < Avo::BaseComponent
  renders_one :trigger
  renders_one :items

  # this is used to trigger the dropdown menu from trigger element
  # data: {action: component.action} => click->dropdown-menu#toggle
  def action
    @action ||= "click->dropdown-menu#toggle"
  end
end
