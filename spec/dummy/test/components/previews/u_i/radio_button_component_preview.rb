module UI
  class RadioButtonComponentPreview < ViewComponent::Preview
    # @!group Interactive Playground

    # Interactive radio button with customizable options
    # @param label text "Label text"
    # @param description text "Description text"
    # @param show_description toggle "Show description"
    # @param checked toggle "Checked"
    # @param disabled toggle "Disabled"
    def playground(
      label: "Label",
      description: "Description",
      show_description: true,
      checked: true,
      disabled: false
    )
      render Avo::UI::RadioButtonComponent.new(
        label: label,
        description: show_description ? description : nil,
        checked: checked,
        disabled: disabled,
        name: "playground-radio"
      )
    end

    # @!endgroup

    # @!group Examples

    # All variants and states (light & dark surfaces, checked & unchecked, enabled & disabled)
    def all_states
      render_with_template(template: "u_i/radio_button_component_preview/all_states")
    end

    # @!endgroup
  end
end
