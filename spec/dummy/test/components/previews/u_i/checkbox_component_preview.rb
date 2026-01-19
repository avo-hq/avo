module UI
  class CheckboxComponentPreview < ViewComponent::Preview
    # @!group Interactive Playground

    # Interactive checkbox with customizable options
    # @param checked toggle "Whether the checkbox is checked"
    # @param indeterminate toggle "Whether the checkbox is in indeterminate state"
    # @param disabled toggle "Whether the checkbox is disabled"
    # @param label text "Checkbox label text"
    # @param description text "Checkbox description text"
    def playground(
      checked: false,
      indeterminate: false,
      disabled: false,
      label: "Label",
      description: "Description"
    )
      render_with_template(
        template: "u_i/checkbox_component_preview/playground",
        locals: {
          checked: checked,
          indeterminate: indeterminate,
          disabled: disabled,
          label: label,
          description: description
        }
      )
    end

    # @!endgroup

    # @!group Examples

    # All checkbox states in a grid showing enabled and disabled variants
    def all_states
      render_with_template(template: "u_i/checkbox_component_preview/all_states")
    end

    # @!endgroup
  end
end
