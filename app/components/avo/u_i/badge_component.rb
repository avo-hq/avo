# frozen_string_literal: true

class Avo::UI::BadgeComponent < Avo::BaseComponent
  VALID_STYLES = %i[solid subtle].freeze unless defined?(VALID_STYLES)
  VALID_COLORS = %i[neutral success info warning danger red orange amber yellow lime green emerald teal cyan sky blue indigo violet purple fuchsia pink rose].freeze unless defined?(VALID_COLORS)

  prop :color do |value|
    normalize_to_valid(value, VALID_COLORS, :neutral)
  end

  prop :style, default: :subtle do |value|
    normalize_to_valid(value, VALID_STYLES, :subtle)
  end

  prop :label
  prop :icon
  prop :classes

  def style_classes
    "badge--#{@style}" if @style.present?
  end

  def color_classes
    "badge--#{@color}" if @color.present?
  end

  private

  def normalize_to_valid(value, valid_options, fallback)
    return fallback if value.blank?

    normalized = value.to_s.to_sym
    valid_options.include?(normalized) ? normalized : fallback
  end
end
