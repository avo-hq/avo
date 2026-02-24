class UI::PopoverComponentPreview < ViewComponent::Preview
  # Popover Component
  # -----------------
  # A container component that wraps content in a floating popover surface.
  # Available in two variants: simple (white) and complex (gray with border).
  #
  # @param type select { choices: [simple, complex] } "simple"
  # @param show_action_row toggle
  # @param action_label text "Menu item"
  def default(type: :simple, show_action_row: false, action_label: "Menu item")
    render_with_template(
      template: "u_i/popover_component_preview/default",
      locals: {
        type: type,
        show_action_row: show_action_row,
        action_label: action_label
      }
    )
  end
end
