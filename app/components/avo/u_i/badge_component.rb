# frozen_string_literal: true

class Avo::UI::BadgeComponent < Avo::BaseComponent
  VALID_STYLES = %i[solid subtle].freeze unless defined?(VALID_STYLES)
  VALID_COLORS = %i[neutral success info warning danger orange yellow green teal blue purple].freeze unless defined?(VALID_COLORS)

  prop :color do |value|
    normalized_value = value.to_s.to_sym
    VALID_COLORS.include?(normalized_value) ? normalized_value : :neutral
  end

  prop :style do |value|
    normalized_value = value.to_s.to_sym
    VALID_STYLES.include?(normalized_value) ? normalized_value : :solid
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
end
