module UI
  class FileUploadItemComponentPreview < ViewComponent::Preview
    layout "component_preview"

    include Avo::ApplicationHelper

    # @!group Examples

    # Default file upload item variants (design only, no actions)
    def default
      render_with_template(template: "u_i/file_upload_item_component_preview/default")
    end

    # @!endgroup
  end
end
