# frozen_string_literal: true

# R5 close-with-dirty-form guard. Rendered inside the slide-out body and
# initially `hidden`; the form Stimulus controller (`bulk_update_form_controller`)
# opens it when Esc / X / backdrop fires with `dirtyKeys.size > 0`.
#
# Focus management (per the focus plan in the plan doc):
#   - Open: focus moves to "Keep editing" (safe default).
#   - Esc within the dialog = "Keep editing" (cancels the discard).
#   - Confirm "Discard changes" = same as full-success close path.
#
# Uses `role="alertdialog"` so AT users get an assertive announcement; the
# `tabler/outline/alert-octagon` icon signals destructive-action.
class Avo::BulkUpdate::DiscardDialogComponent < Avo::BaseComponent
  def icon_name
    "tabler/outline/alert-octagon"
  end
end
