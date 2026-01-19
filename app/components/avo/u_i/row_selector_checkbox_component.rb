# frozen_string_literal: true

class Avo::UI::RowSelectorCheckboxComponent < Avo::BaseComponent
  prop :checked, default: false
  prop :index
  prop :disabled, default: false
  prop :data, default: -> { {} }
  prop :classes
  prop :floating, default: false

  def row_selector_action
    action = "input->item-selector#toggle input->item-select-all#selectRow"

    if Avo.plugin_manager.installed?("avo-pro")
      action += " click->record-selector#toggleMultiple"
    end

    action
  end

  def computed_data
    {
      index: @index,
      action: row_selector_action,
      item_select_all_target: "itemCheckbox",
      tippy: "tooltip",
      **@data
    }
  end
end
