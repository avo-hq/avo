module Avo
  module Themes
    # The public theming tokens, as one list every consumer reads:
    #
    #   * the `avo:theme` generator writes them, commented, into the CSS template
    #   * the built-in theme spec checks each built-in declares the required set
    #   * (phase 2) the Theme Studio form and renderer
    #
    # `derives_from` names the token a value falls back to when unset, so a UI
    # can say "inherits from --color-background" instead of showing a blank.
    # `required` marks the tokens a complete theme is expected to set in both
    # schemes; everything else is optional refinement.
    module Catalog
      unless defined?(Token)
        Token = Struct.new(:name, :group, :kind, :label, :derives_from, :required, keyword_init: true) do
          def required? = required == true
        end

        NEUTRAL_SHADES = [25, 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950].freeze

        GROUPS = {
          neutral: "Neutral scale",
          foundations: "Foundations",
          accent: "Accent",
          semantic: "Semantic",
          chrome: "Chrome",
          shape: "Radii and shape",
          motion: "Motion"
        }.freeze

        TOKENS = [
          *NEUTRAL_SHADES.map { |shade|
            Token.new(name: "--color-avo-neutral-#{shade}", group: :neutral, kind: :color, label: "Neutral #{shade}", required: true)
          },
          Token.new(name: "--color-background", group: :foundations, kind: :color, label: "Page background", derives_from: "--color-avo-neutral-50"),
          Token.new(name: "--color-foreground", group: :foundations, kind: :color, label: "Foreground", derives_from: "--color-avo-neutral-800"),
          Token.new(name: "--color-primary", group: :foundations, kind: :color, label: "Primary surface", derives_from: "--color-white"),
          Token.new(name: "--color-secondary", group: :foundations, kind: :color, label: "Secondary surface", derives_from: "--color-avo-neutral-100"),
          Token.new(name: "--color-tertiary", group: :foundations, kind: :color, label: "Tertiary surface", derives_from: "--color-avo-neutral-200"),
          Token.new(name: "--color-quaternary", group: :foundations, kind: :color, label: "Quaternary surface", derives_from: "--color-avo-neutral-300"),
          Token.new(name: "--color-content", group: :foundations, kind: :color, label: "Text", derives_from: "--color-avo-neutral-950"),
          Token.new(name: "--color-content-secondary", group: :foundations, kind: :color, label: "Muted text", derives_from: "--color-avo-neutral-500"),
          Token.new(name: "--color-accent", group: :accent, kind: :color, label: "Accent", required: true),
          Token.new(name: "--color-accent-content", group: :accent, kind: :color, label: "Accent, subtle UI", required: true),
          Token.new(name: "--color-accent-foreground", group: :accent, kind: :color, label: "Text on accent", required: true),
          Token.new(name: "--color-brand-accent", group: :accent, kind: :color, label: "Picker swatch for the brand accent", derives_from: "--color-accent"),
          Token.new(name: "--color-brand-neutral-400", group: :accent, kind: :color, label: "Picker swatch for the brand neutral", derives_from: "--color-avo-neutral-400"),
          Token.new(name: "--color-success", group: :semantic, kind: :color, label: "Success"),
          Token.new(name: "--color-success-content", group: :semantic, kind: :color, label: "Success, subtle UI"),
          Token.new(name: "--color-info", group: :semantic, kind: :color, label: "Info"),
          Token.new(name: "--color-info-content", group: :semantic, kind: :color, label: "Info, subtle UI"),
          Token.new(name: "--color-warning", group: :semantic, kind: :color, label: "Warning"),
          Token.new(name: "--color-warning-content", group: :semantic, kind: :color, label: "Warning, subtle UI"),
          Token.new(name: "--color-danger", group: :semantic, kind: :color, label: "Danger"),
          Token.new(name: "--color-danger-content", group: :semantic, kind: :color, label: "Danger, subtle UI"),
          Token.new(name: "--color-navbar-background", group: :chrome, kind: :color, label: "Navbar background", derives_from: "--color-avo-neutral-900"),
          Token.new(name: "--color-sidebar-background", group: :chrome, kind: :color, label: "Sidebar background", derives_from: "--color-background"),
          Token.new(name: "--color-main-content-background", group: :chrome, kind: :color, label: "Main content background", derives_from: "--color-primary"),
          Token.new(name: "--color-main-content-border", group: :chrome, kind: :color, label: "Sidebar/content seam", derives_from: "--border-color"),
          Token.new(name: "--color-row-bg", group: :chrome, kind: :color, label: "Table row", derives_from: "--color-primary"),
          Token.new(name: "--color-row-bg-hover", group: :chrome, kind: :color, label: "Table row, hover"),
          Token.new(name: "--color-row-bg-selected", group: :chrome, kind: :color, label: "Table row, selected"),
          Token.new(name: "--focus-outline-color", group: :chrome, kind: :color, label: "Focus ring", derives_from: "--color-info"),
          Token.new(name: "--radius-card", group: :shape, kind: :length, label: "Card radius"),
          Token.new(name: "--radius-card-wrapper", group: :shape, kind: :length, label: "Card wrapper radius"),
          Token.new(name: "--navbar-notch-enabled", group: :shape, kind: :boolean, label: "Navbar notch"),
          Token.new(name: "--navbar-notch-radius", group: :shape, kind: :length, label: "Navbar notch radius"),
          Token.new(name: "--main-content-radius", group: :shape, kind: :length, label: "Main content radius", derives_from: "--navbar-notch-radius"),
          Token.new(name: "--speed-fast", group: :motion, kind: :duration, label: "Fast transitions"),
          Token.new(name: "--speed-moderate", group: :motion, kind: :duration, label: "Moderate transitions"),
          Token.new(name: "--speed-slow", group: :motion, kind: :duration, label: "Slow transitions")
        ].freeze
      end

      def self.all = TOKENS

      def self.required = TOKENS.select(&:required?)

      def self.grouped = TOKENS.group_by(&:group)

      def self.names = TOKENS.map(&:name)
    end
  end
end
