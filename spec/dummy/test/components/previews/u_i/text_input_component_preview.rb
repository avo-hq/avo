module UI
  class TextInputComponentPreview < ViewComponent::Preview
    # @!group Interactive Playground

    # Interactive text input with customizable options
    # @param label text "Placeholder label"
    # @param type select { choices: [text, email, number, password, search, url] } "Input type"
    # @param value text "Input value"
    # @param hint text "Help text"
    # @param error toggle "Show error"
    # @param error_message text "Error message"
    # @param loading toggle "Show loading"
    # @param disabled toggle "Disabled"
    # @param readonly toggle "Read only"
    def playground(
      label: "Label",
      type: "text",
      value: "",
      hint: "Help text (text)",
      error: false,
      error_message: "Error message",
      loading: false,
      disabled: false,
      readonly: false
    )
      render Avo::UI::TextInputComponent.new(
        label: label,
        type: type,
        value: value.presence,
        hint: hint.presence || "Help text (#{type})",
        error: error,
        error_message: error_message,
        loading: loading,
        disabled: disabled,
        readonly: readonly,
        name: "playground-text-input",
        id: "playground-text-input",
        placeholder: "Placeholder (#{type})"
      )
    end

    # @!endgroup

    # @!group Examples

    # All variants and states (light & dark surfaces)
    def all_states
      render_with_template(template: "u_i/text_input_component_preview/all_states")
    end

    # @!endgroup
  end
end
