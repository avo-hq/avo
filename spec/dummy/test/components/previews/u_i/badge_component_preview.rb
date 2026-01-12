module UI
  class BadgeComponentPreview < ViewComponent::Preview
    # @!group Interactive Playground

    # Interactive badge with customizable options
    # @param label text "Badge text"
    # @param color select { choices: [neutral, success, danger, warning, info, orange, yellow, green, teal, blue, purple] } "Badge color"
    # @param style select { choices: [subtle, solid] } "Badge style (solid = dark background with light text, available for all colors)"
    # @param icon text "Icon name (e.g., tabler/outline/paperclip)"
    def playground(
      label: "Purple",
      color: "purple",
      style: "solid",
      icon: "tabler/outline/paperclip"
    )
      render Avo::UI::BadgeComponent.new(
        label: label,
        color: color,
        style: style,
        icon: icon.present? ? icon : nil
      )
    end

    # @!endgroup

    # @!group Examples

    # Semantic color badges (neutral, success, danger, warning, info)
    def semantic_colors
      render_with_template(template: "u_i/badge_component_preview/semantic_colors")
    end

    # Solid style badges (dark backgrounds with light text)
    def solid_style
      render_with_template(template: "u_i/badge_component_preview/solid_style")
    end

    # Subtle style badges (light backgrounds with dark text)
    def subtle_style
      render_with_template(template: "u_i/badge_component_preview/subtle_style")
    end

    # @!endgroup
  end
end
