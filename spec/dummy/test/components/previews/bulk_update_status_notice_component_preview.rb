class BulkUpdateStatusNoticeComponentPreview < ViewComponent::Preview
  # A field-shaped stub so we don't need a full Avo resource graph for previews.
  PreviewField = Struct.new(:id, :name, keyword_init: true)

  def default
    render_with_template(template: "bulk_update_status_notice_component_preview/default")
  end

  def all_share
    render_with_template(template: "bulk_update_status_notice_component_preview/all_share")
  end

  def sample_list
    render_with_template(template: "bulk_update_status_notice_component_preview/sample_list")
  end

  def count_only
    render_with_template(template: "bulk_update_status_notice_component_preview/count_only")
  end
end
