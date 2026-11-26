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
          navbar: "Navbar",
          chrome: "Chrome",
          backgrounds: "Backgrounds",
          spacing: "Spacing",
          typography: "Typography and controls",
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
          # The navbar is a palette of its own so a theme can make it light, tinted,
          # or the same as the page; Paper's dark bar is one choice among those.
          Token.new(name: "--color-navbar-background", group: :navbar, kind: :color, label: "Navbar background", derives_from: "--color-avo-neutral-900"),
          Token.new(name: "--color-navbar-content", group: :navbar, kind: :color, label: "Navbar text and icons", derives_from: "--color-avo-neutral-300"),
          Token.new(name: "--color-navbar-content-hover", group: :navbar, kind: :color, label: "Navbar text and icons, hover", derives_from: "--color-avo-neutral-50"),
          Token.new(name: "--color-navbar-control-background", group: :navbar, kind: :color, label: "Navbar controls (search, picker)", derives_from: "--color-avo-neutral-800"),
          Token.new(name: "--color-navbar-control-background-hover", group: :navbar, kind: :color, label: "Navbar controls, hover", derives_from: "--color-avo-neutral-700"),
          Token.new(name: "--color-navbar-control-border", group: :navbar, kind: :color, label: "Navbar controls, border", derives_from: "--color-avo-neutral-700"),
          Token.new(name: "--color-navbar-control-content", group: :navbar, kind: :color, label: "Navbar controls, text", derives_from: "--color-avo-neutral-50"),
          Token.new(name: "--color-navbar-control-muted", group: :navbar, kind: :color, label: "Navbar controls, muted text", derives_from: "--color-avo-neutral-400"),
          Token.new(name: "--color-navbar-active-background", group: :navbar, kind: :color, label: "Navbar active item", derives_from: "--color-avo-neutral-950"),
          Token.new(name: "--color-navbar-active-content", group: :navbar, kind: :color, label: "Navbar active item, text", derives_from: "--color-avo-neutral-50"),
          Token.new(name: "--color-sidebar-background", group: :chrome, kind: :color, label: "Sidebar background", derives_from: "--color-background"),
          Token.new(name: "--color-main-content-background", group: :chrome, kind: :color, label: "Main content background", derives_from: "--color-primary"),
          Token.new(name: "--color-main-content-border", group: :chrome, kind: :color, label: "Sidebar/content seam", derives_from: "--border-color"),
          Token.new(name: "--color-row-bg", group: :chrome, kind: :color, label: "Table row", derives_from: "--color-primary"),
          Token.new(name: "--color-row-bg-hover", group: :chrome, kind: :color, label: "Table row, hover"),
          Token.new(name: "--color-row-bg-selected", group: :chrome, kind: :color, label: "Table row, selected"),
          Token.new(name: "--focus-outline-color", group: :chrome, kind: :color, label: "Focus ring", derives_from: "--color-info"),
          Token.new(name: "--main-content-background-image", group: :backgrounds, kind: :image, label: "Main content image or gradient"),
          Token.new(name: "--main-content-background-size", group: :backgrounds, kind: :text, label: "Background size"),
          Token.new(name: "--main-content-background-position", group: :backgrounds, kind: :text, label: "Background position"),
          Token.new(name: "--main-content-background-repeat", group: :backgrounds, kind: :text, label: "Background repeat"),
          Token.new(name: "--sidebar-background-image", group: :backgrounds, kind: :image, label: "Sidebar image or gradient"),
          Token.new(name: "--density-factor", group: :spacing, kind: :number, label: "Density multiplier"),
          Token.new(name: "--table-cell-padding-block", group: :spacing, kind: :length, label: "Table cell vertical padding"),
          Token.new(name: "--field-padding-block", group: :spacing, kind: :length, label: "Field vertical padding"),
          Token.new(name: "--field-stacked-padding-block", group: :spacing, kind: :length, label: "Stacked field vertical padding"),
          Token.new(name: "--sidebar-item-padding-block", group: :spacing, kind: :length, label: "Sidebar link vertical padding"),
          Token.new(name: "--sidebar-subitem-padding-block", group: :spacing, kind: :length, label: "Sidebar subitem vertical padding"),
          Token.new(name: "--sidebar-group-gap", group: :spacing, kind: :length, label: "Sidebar group spacing"),
          Token.new(name: "--panel-gap", group: :spacing, kind: :length, label: "Panel spacing"),
          Token.new(name: "--panel-stack-gap", group: :spacing, kind: :length, label: "Space between panels"),
          Token.new(name: "--header-gap", group: :spacing, kind: :length, label: "Header and toolbar control spacing"),
          Token.new(name: "--content-padding", group: :spacing, kind: :length, label: "Page content padding"),
          Token.new(name: "--header-title-font-size", group: :typography, kind: :length, label: "Page title size"),
          Token.new(name: "--header-title-line-height", group: :typography, kind: :length, label: "Page title line height"),
          Token.new(name: "--grid-card-gap", group: :spacing, kind: :length, label: "Grid gap"),
          Token.new(name: "--grid-card-padding", group: :spacing, kind: :length, label: "Grid card padding"),
          Token.new(name: "--card-padding", group: :spacing, kind: :length, label: "Padded card body"),
          Token.new(name: "--font-sans", group: :typography, kind: :text, label: "UI font family"),
          Token.new(name: "--font-heading", group: :typography, kind: :text, label: "Heading font family", derives_from: "--font-sans"),
          Token.new(name: "--font-description", group: :typography, kind: :text, label: "Page description font family", derives_from: "--font-sans"),
          Token.new(name: "--text-sm", group: :typography, kind: :length, label: "Small text size"),
          Token.new(name: "--text-base", group: :typography, kind: :length, label: "Base text size"),
          Token.new(name: "--control-padding-block", group: :typography, kind: :length, label: "Default input vertical padding"),
          Token.new(name: "--control-font-size", group: :typography, kind: :length, label: "Default input text size"),
          Token.new(name: "--control-line-height", group: :typography, kind: :length, label: "Default input line height"),
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
