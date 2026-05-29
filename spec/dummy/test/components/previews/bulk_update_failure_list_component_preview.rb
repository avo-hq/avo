class BulkUpdateFailureListComponentPreview < ViewComponent::Preview
  def default
    render_with_template(template: "bulk_update_failure_list_component_preview/default")
  end

  def empty
    render_with_template(template: "bulk_update_failure_list_component_preview/empty")
  end

  def one_validation
    render_with_template(template: "bulk_update_failure_list_component_preview/one_validation")
  end

  def mixed_reasons
    render_with_template(template: "bulk_update_failure_list_component_preview/mixed_reasons")
  end

  def with_custom_reason
    render_with_template(template: "bulk_update_failure_list_component_preview/with_custom_reason")
  end
end
