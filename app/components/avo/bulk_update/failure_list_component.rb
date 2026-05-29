# frozen_string_literal: true

# R11 per-record failure list rendered in place of the field stack on partial
# failure. Each row carries a reason chip + a user-facing message (Rails
# validation messages are kept here for human display; they are STRIPPED from
# the audit event payload to prevent PII leakage through subscribers).
#
# The component exposes a "Retry failed" button that resubmits the form with
# `avo_resource_ids` collapsed to just the failed subset.
#
# `failed` is an array of:
#   { id: <record_id>, reason: <symbol>, message: <optional string> }
#
# `reason` is one of:
#   - :unauthorized_at_write       (lock-x icon)
#   - :validation                  (alert-circle icon)
#   - :concurrent_modification     (refresh-alert icon)
#   - any other Symbol from a custom override (generic alert-triangle)
class Avo::BulkUpdate::FailureListComponent < Avo::BaseComponent
  prop :failed, default: -> { [] }
  prop :resource, default: nil
  prop :current_page_ids, default: nil

  KNOWN_REASONS = %i[unauthorized_at_write validation concurrent_modification].freeze

  def heading_icon
    "tabler/outline/alert-triangle"
  end

  def reason_icon(reason)
    case reason.to_sym
    when :unauthorized_at_write then "tabler/outline/lock-x"
    when :validation then "tabler/outline/alert-circle"
    when :concurrent_modification then "tabler/outline/refresh-alert"
    else "tabler/outline/alert-triangle"
    end
  end

  def reason_label(reason)
    if KNOWN_REASONS.include?(reason.to_sym)
      I18n.t("avo.bulk_update.failure_list.reasons.#{reason}")
    else
      I18n.t("avo.bulk_update.failure_list.reasons.custom", reason: reason.to_s.humanize)
    end
  end

  # Comma-joined failed IDs used to repopulate the hidden `avo_resource_ids`
  # input on retry. The form's Stimulus controller writes this into the input
  # via the `retry-failed-ids` data attribute on the retry button so the next
  # POST naturally goes through the standard `set_query` + cap + per-record
  # `update?` filter (no fast-path).
  def failed_ids_csv
    @failed.map { |f| f[:id] }.join(",")
  end

  def truncate_message(message)
    return nil if message.nil? || message == ""

    helpers.truncate(message.to_s, length: 120, omission: "...")
  end
end
