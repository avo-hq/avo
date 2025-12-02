# frozen_string_literal: true

module Avo
  module UI
    # Centralized color definitions for Avo UI components
    # Colors are based on Figma design system specifications
    module Colors
      # Badge and UI component color definitions with exact hex codes
      DEFINITIONS = {
        'secondary' => { text: '#171717', bg: '#F6F6F6' },
        'success' => { text: '#0D8E54', bg: '#D3F8E0' },
        'informative' => { text: '#068AFF', bg: '#D6F1FF' },
        'warning' => { text: '#DB6704', bg: '#FFEFC6' },
        'error' => { text: '#DE3024', bg: '#FEE4E2' },

        'orange' => { text: '#C2410C', bg: '#FFEDD5' },
        'orange-secondary' => { text: '#F6F6F6', bg: '#FB923C' },
        'yellow' => { text: '#FB923C', bg: '#FEF9C3' },
        'yellow-secondary' => { text: '#F6F6F6', bg: '#FACC15' },
        'green' => { text: '#15803D', bg: '#DCFCE7' },
        'green-secondary' => { text: '#F6F6F6', bg: '#22C55E' },
        'teal' => { text: '#0F766E', bg: '#CCFBF1' },
        'teal-secondary' => { text: '#F6F6F6', bg: '#2DD4BF' },
        'blue' => { text: '#1D4ED8', bg: '#DBEAFE' },
        'blue-secondary' => { text: '#F6F6F6', bg: '#3B82F6' },
        'purple' => { text: '#7E22CE', bg: '#F3E8FF' },
        'purple-secondary' => { text: '#F6F6F6', bg: '#A855F7' }
      }.freeze

      # Color name aliases for backward compatibility
      ALIASES = {
        'info' => 'informative',
        'danger' => 'error'
      }.freeze

      # All valid color names (including aliases)
      ALL = (DEFINITIONS.keys + ALIASES.keys).freeze

      # Normalize a color name (resolve aliases)
      def self.normalize(color_name)
        ALIASES[color_name.to_s] || color_name.to_s
      end

      # Get color definition for a given color name
      def self.get(color_name, fallback: 'secondary')
        normalized = normalize(color_name)
        DEFINITIONS[normalized] || DEFINITIONS[fallback]
      end

      # Check if a color is valid
      def self.valid?(color_name)
        ALL.include?(color_name.to_s)
      end
    end
  end
end

