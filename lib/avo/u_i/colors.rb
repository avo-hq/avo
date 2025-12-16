# frozen_string_literal: true

module Avo
  module UI
    # Color validation and aliases for Avo UI components
    # Actual color values are defined in CSS variables (see css/variables.css)
    module Colors
      # Valid color names for badge and UI components
      # Colors are implemented via CSS variables and BEM classes
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

      # Color name aliases for backward compatibility
      ALIASES = {
        "info" => "informative",
        "danger" => "error"
      }.freeze

      # All valid color names (including aliases)
      ALL = (VALID_COLORS + ALIASES.keys).freeze

      # Normalize a color name (resolve aliases)
      def self.normalize(color_name)
        ALIASES[color_name.to_s] || color_name.to_s
      end

      # Check if a color is valid
      def self.valid?(color_name)
        ALL.include?(color_name.to_s)
      end
    end
  end
end
