module UI
  class InputComponentPreview < ViewComponent::Preview
    # @!group Examples

    # Default input with common states
    def default
      render_with_template(template: "u_i/input_component_preview/default")
    end

    # @!endgroup
  end
end
