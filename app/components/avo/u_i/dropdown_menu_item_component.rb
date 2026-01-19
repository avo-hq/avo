# frozen_string_literal: true

class Avo::UI::DropdownMenuItemComponent < Avo::BaseComponent
  prop :title
  prop :icon
  prop :url
  prop :data
  prop :classes
  prop :method
  prop :target
  prop :turbo
  prop :type, default: :button

  def item_data
    merged = {action: "click->dropdown#dropdownItemActions"}
    merged[:turbo] = @turbo unless @turbo.nil?
    merged.merge(@data || {})
  end
end
