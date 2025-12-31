# frozen_string_literal: true

class Avo::UI::BadgeComponent < Avo::BaseComponent
  unless defined?(VALID_STYLES)
    VALID_STYLES = %w[solid subtle].freeze
  end

  unless defined?(VALID_COLORS)
    VALID_COLORS = %w[
      secondary
      success
      informative
      warning
      error
      orange
      yellow
      green
      teal
      blue
      purple
    ].freeze
  end

  prop :color do |value|
    value = value.to_s

    VALID_COLORS.include?(value) ? value : "secondary"
  end

  prop :style do |value|
    value = value.to_s

    VALID_STYLES.include?(value) ? value : "subtle"
  end

  prop :label, default: ""
  prop :icon
  prop :icon_only, default: false
  prop :classes, default: ""

  private

  def icon_only?
    @icon_only || (@icon.present? && @label.blank?)
  end
end
