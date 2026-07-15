# frozen_string_literal: true

# Compact numeric pill used next to a label or title — e.g. the active-filter
# count on the filters bar or an unread-notification count. Extracted from the
# filters bar so the same accent-tinted style can be reused anywhere a small
# count needs to sit alongside text.
class Avo::UI::CountComponent < Avo::BaseComponent
  prop :count
  prop :classes, default: nil
  # Optional accessible name. When set, it becomes the pill's aria-label so a
  # screen reader announces something meaningful (e.g. "42 records") instead of
  # a bare number. Visible text is unchanged.
  prop :label, default: nil
end
