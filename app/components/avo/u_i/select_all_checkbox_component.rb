# frozen_string_literal: true

class Avo::UI::SelectAllCheckboxComponent < Avo::BaseComponent
  prop :checked, default: false
  prop :indeterminate, default: false
  prop :disabled, default: false
  prop :data, default: -> { {} }
  prop :classes

  def computed_data
    {
      action: "input->item-select-all#toggle",
      item_select_all_target: "checkbox",
      tippy: "tooltip",
      **@data
    }
  end
end
