# frozen_string_literal: true

class Avo::RowSelectorComponent < Avo::BaseComponent
  prop :floating, default: false
  prop :size, default: :md
  prop :index

  def data_action
    data = "input->item-selector#toggle input->item-select-all#selectRow"

    if Avo.plugin_manager.installed?(:avo_pro)
      data += " click->record-selector#toggleMultiple"
    end

    data
  end
end
