class BulkUpdateBannerComponentPreview < ViewComponent::Preview
  def default
    render_with_template(
      template: "bulk_update_banner_component_preview/default"
    )
  end

  def with_exclusions
    render_with_template(
      template: "bulk_update_banner_component_preview/with_exclusions"
    )
  end

  def cap_exceeded
    render_with_template(
      template: "bulk_update_banner_component_preview/cap_exceeded"
    )
  end

  def n_too_small
    render_with_template(
      template: "bulk_update_banner_component_preview/n_too_small"
    )
  end

  def no_records_editable
    render_with_template(
      template: "bulk_update_banner_component_preview/no_records_editable"
    )
  end
end
