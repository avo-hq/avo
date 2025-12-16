# frozen_string_literal: true

class Avo::UI::BadgeComponent < Avo::BaseComponent
  STYLES = %w[solid subtle].freeze

  # Use centralized color validation
  VALID_COLORS = Avo::UI::Colors::ALL

  def initialize(
    label: "",
    color: "secondary",
    style: "subtle",
    icon: nil,
    icon_only: false
  )
    @label = label.to_s
    @color = normalize_color(color.to_s)
    @style = style.to_s
    @icon = icon&.to_s
    @icon_only = icon_only

    validate_params!

    super()
  end

  private

  attr_reader :label, :color, :style, :icon, :icon_only

  def normalize_color(value)
    # Normalize aliases (info → informative, danger → error) using centralized Colors module
    normalized = Avo::UI::Colors.normalize(value)

    # Fallback to 'secondary' if color is invalid
    Avo::UI::Colors.valid?(normalized) ? normalized : "secondary"
  end

  def validate_params!
    raise ArgumentError, "Invalid style: #{style}. Must be one of #{STYLES.join(", ")}" unless STYLES.include?(style)

    if icon_only && label.present?
      raise ArgumentError, "icon_only cannot be true when label is present"
    end

    if icon_only && icon.blank?
      raise ArgumentError, "icon_only requires an icon to be present"
    end
  end

  def badge_classes
    classes = ["badge"]

    # Style modifier
    classes << "badge--#{style}"

    # Color modifier (map 'secondary' to 'default' for BEM class)
    color_class = (color == "secondary") ? "default" : color
    classes << "badge--#{color_class}"

    # Icon-only modifier
    classes << "badge--icon-only" if icon_only?

    classes.compact.join(" ")
  end

  def icon_only?
    @icon_only || (icon.present? && label.blank?)
  end

  def icon_classes
    "badge__icon"
  end

  def render_icon_content
    return unless icon.present?

    helpers.svg(icon, class: icon_classes)
  end
end
