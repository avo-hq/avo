module UI
  class PopoverComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # @!group Examples

    # Default popover component with per-page style options
    def default
      render_with_template(template: "u_i/popover_component_preview/default")
    end

    # @!endgroup
  end
end
