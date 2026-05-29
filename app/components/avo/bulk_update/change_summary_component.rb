# frozen_string_literal: true

# R8 live "what's about to change" surface, rendered above the Submit button.
#
# Static markup only - an empty `aria-live="polite"` region. The form Stimulus
# controller (`bulk_update_form_controller`) listens for
# `bulk-update:field-changed` events and rewrites the region's contents in
# place as dirty keys change. Content shape per the plan's spec:
#
#   "Set <field>=<value> on <N> records."
#   "Set stage=success, priority=high on 47 records."
#   Two lines max; beyond that "...and N more fields."
#
# The component renders ONLY when `@resource.bulk_update_change_summary` is
# true (R9 disable flag); the caller is responsible for that branch.
class Avo::BulkUpdate::ChangeSummaryComponent < Avo::BaseComponent
  prop :records_count

  def icon_name
    "tabler/outline/list-check"
  end
end
