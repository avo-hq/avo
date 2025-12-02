# frozen_string_literal: true

class Avo::UI::BadgeComponent < Avo::BaseComponent
  STYLES = %w[solid subtle].freeze

  # Use centralized color definitions
  COLOR_DEFINITIONS = Avo::UI::Colors::DEFINITIONS
  COLOR_ALIASES = Avo::UI::Colors::ALIASES
  VALID_COLORS = Avo::UI::Colors::ALL

  def initialize(
    label: '',
    color: 'secondary',
    style: 'subtle',
    icon: nil,
    icon_position: 'left',
    rounded: true,
    **options
  )
    @label = label.to_s
    @color = normalize_color(color.to_s)
    @style = style.to_s
    @icon = icon&.to_s
    @icon_position = icon_position.to_s
    @rounded = rounded
    @options = options

    validate_params!

    super()
  end

  private

  attr_reader :label, :color, :style, :icon, :icon_position, :rounded, :options

  def normalize_color(value)
    # Map aliases to their canonical color names
    normalized = COLOR_ALIASES[value] || value

    # Fallback to 'secondary' if color is invalid
    VALID_COLORS.include?(normalized) ? normalized : 'secondary'
  end

  def color_definition
    # For solid style, use -secondary variant if it exists (dark bg, light text)
    if @style == 'solid'
      secondary_color = "#{color}-secondary"
      return COLOR_DEFINITIONS[secondary_color] if COLOR_DEFINITIONS.key?(secondary_color)
    end

    # Default: use the base color (always valid due to normalize_color)
    COLOR_DEFINITIONS[color]
  end

  def text_color
    color_definition[:text]
  end

  def bg_color
    color_definition[:bg]
  end

  def validate_params!
    raise ArgumentError, "Invalid style: #{style}. Must be one of #{STYLES.join(', ')}" unless STYLES.include?(style)

    return if %w[left right].include?(icon_position)

    raise ArgumentError, "Invalid icon_position: #{icon_position}. Must be 'left' or 'right'"
  end

  def badge_classes
    classes = [
      'inline-flex items-center justify-center transition-colors',
      'focus:outline-none focus:ring-2 focus:ring-offset-2',
      'px-2 py-0.5 text-xs gap-0.5 text-center' # x:8px, y:2px, gap:2px, height:24px
    ]

    classes << 'rounded-md' if rounded

    classes.compact.join(' ')
  end

  def badge_style
    # Figma specs: height:24px, font-size:12px, font-weight:500, line-height:16px
    "height: 24px; font-size: 12px; font-weight: 500; line-height: 16px; background-color: #{bg_color}; color: #{text_color};"
  end

  def icon_classes
    'shrink-0 w-3 h-3'
  end

  def icon_style
    "color: #{text_color};"
  end

  def render_icon_content
    return unless icon.present?

    return unless icon_position == 'left'

    helpers.svg(icon, class: icon_classes, style: icon_style)
  end

  def render_icon_content_right
    return unless icon.present? && icon_position == 'right'

    helpers.svg(icon, class: icon_classes, style: icon_style)
  end
end
