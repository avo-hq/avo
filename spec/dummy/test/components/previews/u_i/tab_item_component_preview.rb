# frozen_string_literal: true

class UI::TabComponentPreview < ViewComponent::Preview
  # @!group States

  # Inactive tab item (group variant - no border)
  def inactive
    render Avo::UI::TabComponent.new(label: "Tab", active: false, variant: :group)
  end

  # Active tab item (group variant - no border)
  def active
    render Avo::UI::TabComponent.new(label: "Tab", active: true, variant: :group)
  end

  # Tab item with icon (scope variant - with border)
  def with_icon
    render Avo::UI::TabComponent.new(
      label: "Tab",
      icon: "heroicons/outline/external-link",
      active: false,
      variant: :scope
    )
  end

  # Active tab item with icon (scope variant - with border)
  def active_with_icon
    render Avo::UI::TabComponent.new(
      label: "Tab",
      icon: "heroicons/outline/external-link",
      active: true,
      variant: :scope
    )
  end

  # @!endgroup

  # @!group Interactive Playground

  # Interactive tab item with customizable options
  # @param label text "Tab label"
  # @param active toggle "Is tab active"
  # @param icon text "Icon name (optional)"
  # @param variant select { choices: [group, scope] } "Tab variant style"
  def playground(
    label: "Tab",
    active: false,
    icon: nil,
    variant: :group
  )
    render Avo::UI::TabComponent.new(
      label: label,
      active: active,
      icon: icon.presence,
      variant: variant.to_sym
    )
  end
end
