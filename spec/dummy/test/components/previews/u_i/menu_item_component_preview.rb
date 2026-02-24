module UI
  class MenuItemComponentPreview < ViewComponent::Preview
    # @!group Interactive Playground

    # Interactive menu item with customizable options
    # @param type select { choices: [default, action, header] } "Menu item type"
    # @param label text "Menu item"
    # @param icon text "Icon name (e.g., tabler/outline/plus)"
    # @param disabled toggle
    def playground(
      type: "action",
      label: "Menu item",
      icon: "tabler/outline/plus",
      disabled: false
    )
      render Avo::UI::MenuItemComponent.new(
        type: type,
        label: label,
        icon: icon.present? ? icon : nil,
        disabled: ActiveModel::Type::Boolean.new.cast(disabled)
      )
    end

    # @!endgroup

    # Default preview showing all variations
    def default
      render_with_template(template: "u_i/menu_item_component_preview/default")
    end
  end
end
