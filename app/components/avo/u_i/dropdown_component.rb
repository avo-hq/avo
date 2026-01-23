# frozen_string_literal: true

class Avo::UI::DropdownComponent < Avo::BaseComponent
  renders_one :trigger
  renders_one :items

  def action
    @action ||= "click->dropdown-menu#toggle"
  end
end
