module UI
  class DropdownComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # @!group Interactive Playground

    # Interactive dropdown menu with configurable items
    # @param first_label text "First item label"
    # @param second_label text "Second item label"
    # @param third_label text "Third item label"
    # @param with_icons toggle "Show icons"
    # @param as_links toggle "Render items as links"
    def playground(
      first_label: "Edit",
      second_label: "View",
      third_label: "Delete",
      with_icons: true,
      as_links: false
    )
      render_with_template(
        template: "u_i/dropdown_component_preview/playground",
        locals: {
          first_label: first_label,
          second_label: second_label,
          third_label: third_label,
          with_icons: with_icons,
          as_links: as_links
        }
      )
    end

    # @!endgroup

    # @!group Examples

    # Default dropdown component variants
    def default
      render_with_template(template: "u_i/dropdown_component_preview/default")
    end
    # @!endgroup
  end
end
