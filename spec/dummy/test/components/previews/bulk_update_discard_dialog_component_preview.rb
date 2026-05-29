class BulkUpdateDiscardDialogComponentPreview < ViewComponent::Preview
  # @label Default (hidden until Esc/X/backdrop fires with dirty keys)
  def default
    render_with_template(template: "bulk_update_discard_dialog_component_preview/default")
  end

  # @label Open (hidden attribute removed for visual review)
  def open
    render_with_template(template: "bulk_update_discard_dialog_component_preview/open")
  end
end
