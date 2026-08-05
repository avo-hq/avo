# frozen_string_literal: true

class Avo::RowSelectorComponent < Avo::BaseComponent
  prop :floating, default: false
  prop :index
  prop :checked, default: false

  # Shift-select is wired on table rows only: grid items render this component without an index and
  # have no table row for the controller to walk up to.
  def data_action
    data = "input->item-selector#toggle input->item-select-all#selectRow"

    data += " click->record-selector#toggleMultiple" if @index.present?

    data
  end
end
