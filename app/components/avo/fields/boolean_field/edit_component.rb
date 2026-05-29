# frozen_string_literal: true

class Avo::Fields::BooleanField::EditComponent < Avo::Fields::EditComponent
  delegate :as_toggle?, to: :@field

  # Sentinel value submitted by the "Unchanged" radio. The dirty-tracking
  # controller treats `Unchanged` as the baseline; since it is the default-checked
  # state, no `bulk-update:field-changed` event fires and the form controller
  # disables the radio group before submission. The sentinel ensures that even if
  # the JS fails open, the server's blank-skip pass drops the value (this string is
  # not blank but the controller filters out any submitted boolean key whose value
  # equals this constant).
  BULK_EDIT_UNCHANGED = "unchanged"

  def bulk_edit_radio_id(state)
    "#{@form.object_name}_#{@field.id}_#{state}"
  end
end
