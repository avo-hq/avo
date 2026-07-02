module UI
  class CheckboxListFieldComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # @!group Examples

    def default
      render_with_template(template: "u_i/checkbox_list_field_component_preview/default")
    end

    # @!endgroup
  end
end
