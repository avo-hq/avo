module UI
  class PopoverComponentPreview < ViewComponent::Preview
    layout "component_preview"

    def default
      render_with_template(template: "u_i/popover_component_preview/default")
    end
  end
end
