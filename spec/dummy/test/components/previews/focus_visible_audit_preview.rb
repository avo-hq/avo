# frozen_string_literal: true

# Audit page for :focus-visible coverage across native elements and Avo components.
# Tab through the page to verify every focusable item shows the same focus ring
# (--focus-outline).
class FocusVisibleAuditPreview < Lookbook::Preview
  include Avo::ApplicationHelper
  include ::ApplicationHelper

  def default
    render_with_template(template: "focus_visible_audit_preview/default")
  end
end
