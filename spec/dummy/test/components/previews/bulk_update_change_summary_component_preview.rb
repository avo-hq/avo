class BulkUpdateChangeSummaryComponentPreview < ViewComponent::Preview
  # @label Default (hidden until first dirty key)
  def default
    render_with_template(template: "bulk_update_change_summary_component_preview/default")
  end

  # @label With one dirty field (simulated, hidden attribute removed)
  def one_dirty_field
    render_with_template(template: "bulk_update_change_summary_component_preview/one_dirty_field")
  end

  # @label Many dirty fields with truncation overflow
  def many_dirty_fields_truncated
    render_with_template(template: "bulk_update_change_summary_component_preview/many_dirty_fields_truncated")
  end
end
