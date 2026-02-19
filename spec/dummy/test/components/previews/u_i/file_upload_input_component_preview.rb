module UI
  class FileUploadInputComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # @!group Examples

    # Default file upload input variants
    def default
      render_with_template(template: "u_i/file_upload_input_component_preview/default")
    end

    # @!endgroup
  end
end
