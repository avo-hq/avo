class Sidebar::LinkComponentPreview < ViewComponent::Preview
  # Navigation Item Component
  # -------------------------
  # A navigation item component for the sidebar with multiple types and states.
  #
  # @param label text "Navigation item"
  # @param type select { choices: [item, group, sub_item] } "item"
  # @param disabled toggle
  # @param counter text ""
  # @param actions toggle
  # @param icon text "tabler/outline/layout-dashboard"
  # @param path text "/example"
  def default(
    label: "Navigation item",
    type: :item,
    disabled: false,
    counter: nil,
    actions: false,
    icon: "tabler/outline/layout-dashboard",
    path: "/example"
  )
    render_with_template(
      template: "sidebar/link_component_preview/default",
      locals: {
        label:,
        type:,
        disabled:,
        counter:,
        actions:,
        icon:,
        path:
      }
    )
  end

  # All types and states
  # Shows all navigation item types with their various states
  def all_states
    render_with_template(template: "sidebar/link_component_preview/all_states")
  end
end
