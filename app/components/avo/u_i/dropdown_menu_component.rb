# frozen_string_literal: true

class Avo::UI::DropdownMenuComponent < Avo::BaseComponent
  renders_many :items, "Avo::UI::DropdownMenuItemComponent"

  prop :data
  prop :classes
  prop :hidden, default: true

  def merged_data
    {
      dropdown_target: "dropdownMenuComponent",
      transition_enter: "transition ease-out duration-100",
      transition_enter_start: "transform opacity-0 -translate-y-1",
      transition_enter_end: "transform opacity-100 translate-y-0",
      transition_leave: "transition ease-in duration-75",
      transition_leave_start: "transform opacity-100 translate-y-0",
      transition_leave_end: "transform opacity-0 -translate-y-1"
    }.merge(@data || {})
  end
end
