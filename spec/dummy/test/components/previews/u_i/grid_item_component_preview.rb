module UI
  class GridItemComponentPreview < ViewComponent::Preview
    # @!group Interactive Playground

    # Interactive grid item with customizable options
    # @param title text "Title"
    # @param description text "Description"
    # @param badge_label text "Badge"
    # @param badge_color select { choices: [neutral, success, danger, warning, info, blue, green, purple] } "Badge color"
    # @param seed_image select { choices: [none, macbook, watch, iphone, ipod] } "Seed image for testing"
    # @param image text "Custom image URL (overrides seed image)"
    # @param checkbox_checked toggle "Checkbox checked"
    def playground(
      title: "Title",
      description: "Description",
      badge_label: "Badge",
      badge_color: "blue",
      seed_image: "none",
      image: "",
      checkbox_checked: false
    )
      render_with_template(
        template: "u_i/grid_item_component_preview/playground",
        locals: {
          title: title,
          description: description,
          badge_label: badge_label,
          badge_color: badge_color,
          seed_image: seed_image,
          image: image,
          checkbox_checked: checkbox_checked
        }
      )
    end

    # @!endgroup

    # @!group Examples

    # Default grid item
    def default
      render_with_template(template: "u_i/grid_item_component_preview/default")
    end

    # Mixed cases - 8 items showing various combinations
    def mixed_cases
      render_with_template(template: "u_i/grid_item_component_preview/mixed_cases")
    end

    # @!endgroup
  end
end
