class BadgeComponentPreview < ViewComponent::Preview
  # @!group Types

  # Default badge
  def default
    render Avo::UI::BadgeComponent.new(label: 'Badge')
  end

  # Badge with icon
  def with_icon
    render Avo::UI::BadgeComponent.new(
      label: 'Badge',
      icon: 'avo/paperclip',
      color: 'secondary'
    )
  end

  # @!endgroup

  # @!group Interactive Playground

  # Interactive badge with customizable options
  # @param label text "Badge text"
  # @param color select { choices: [secondary, success, error, warning, informative, orange, yellow, green, teal, blue, purple] } "Badge color"
  # @param style select { choices: [subtle, solid] } "Badge style (solid = dark background for orange, yellow, green, teal, blue, purple)"
  # @param icon text "Icon name (e.g., avo/paperclip)"
  # @param icon_position select { choices: [left, right] } "Icon position"
  # @param rounded toggle "Rounded corners"
  def playground(
    label: 'Badge',
    color: 'purple',
    style: 'solid',
    icon: 'avo/paperclip',
    icon_position: 'left',
    rounded: true
  )
    render Avo::UI::BadgeComponent.new(
      label: label,
      color: color,
      style: style,
      icon: icon.present? ? icon : nil,
      icon_position: icon_position,
      rounded: rounded
    )
  end

  # @!endgroup

  # @!group Examples

  # Semantic color badges (secondary, success, error, warning, informative)
  def semantic_colors
    render_with_template(template: 'badge_component_preview/semantic_colors')
  end

  # Solid style badges (dark backgrounds with light text)
  def solid_style
    render_with_template(template: 'badge_component_preview/solid_style')
  end

  # Subtle style badges (light backgrounds with dark text)
  def subtle_style
    render_with_template(template: 'badge_component_preview/subtle_style')
  end

  # @!endgroup
end
