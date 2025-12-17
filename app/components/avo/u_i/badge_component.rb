# frozen_string_literal: true

class Avo::UI::BadgeComponent < Avo::BaseComponent
  STYLES = %w[solid subtle].freeze

  prop :label, default: ""
  prop :color, default: "secondary"
  prop :style, default: "subtle"
  prop :icon
  prop :icon_only, default: false
  prop :classes, default: ""

  private

  def normalize_color(value)
    return "secondary" if value.blank?

    normalized = Avo::UI::Colors.normalize(value)
    Avo::UI::Colors.valid(normalized) ? normalized : "secondary"
  end

  def badge_classes
    classes = ["badge"]

    # Add custom classes if provided
    classes << @classes if @classes.present?

    style_value = normalize_style(@style).to_s
    classes << "badge--#{style_value}" if style_value.present?

    color_value = normalize_color(@color).to_s
    classes << "badge--#{color_value}" if color_value.present?

    # Icon-only modifier
    classes << "badge--icon-only" if icon_only?

    classes.compact.join(" ")
  end

  def normalize_style(value)
    style_str = value.to_s
    STYLES.include?(style_str) ? style_str : "subtle"
  end

  def icon_only?
    @icon_only || (@icon.present? && @label.blank?)
  end

  def icon_classes
    "badge__icon"
  end

  def render_icon
    return unless @icon.present?

    helpers.svg(@icon, class: icon_classes)
  end
end
