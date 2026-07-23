class Avo::Configuration::Appearance
  attr_reader :scheme, # :auto | :light | :dark
    :neutral, # Symbol — default theme selection (e.g. :slate, :brand)
    :accent,  # Symbol — default accent selection (e.g. :blue, :brand)
    :neutral_colors, # Hash{ 25 => ..., 50 => ..., ..., 950 => ... } — full 12-shade brand override (single palette, applied in both light and dark mode)
    :accent_colors,  # Hash{ color:, content:, foreground: } — three-token brand override (single palette, applied in both light and dark mode)
    :main_content_background, # String — any CSS `background` value (image url(), gradient, color, or shorthand) for the main content section; nil leaves the themed default
    :neutrals, # Array[String] — available neutral theme names
    :accents, # Array[String] — available accent color names
    :lock, # Array[Symbol] — subset of [:scheme, :neutral, :accent]
    :persistence, # :cookie | :database
    :logo,
    :logo_dark,
    :logomark,
    :logomark_dark,
    :favicon,
    :favicon_dark,
    :chart_colors,
    :placeholder,
    :picker_layout, # :inline | :dropdown — navbar switcher layout (auto-collapses to dropdown below lg:)
    :load_settings_block,
    :save_settings_block

  # Guarded so the file is safe to be loaded more than once (Zeitwerk + the
  # gem's own require_relative chain can both touch this file). Re-assigning
  # frozen constants would otherwise emit "already initialized" warnings.
  unless defined?(PICKER_LAYOUTS)
    PICKER_LAYOUTS = [:inline, :dropdown].freeze

    DEFAULT_NEUTRALS = %w[brand slate stone gray zinc neutral taupe mauve mist olive].freeze
    DEFAULT_ACCENTS = %w[brand red orange amber yellow lime green emerald teal cyan sky blue indigo violet purple fuchsia pink rose].freeze
    LOCKABLE = %i[scheme neutral accent].freeze

    NEUTRAL_SHADES = [25, 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950].freeze
    ACCENT_TOKENS = [:color, :content, :foreground].freeze
    ACCENT_TOKEN_VAR_NAMES = {
      color: "--color-accent",
      content: "--color-accent-content",
      foreground: "--color-accent-foreground"
    }.freeze

    DEFAULTS = {
      scheme: :auto,
      persistence: :cookie,
      logo: "avo/logo.png",
      logomark: "avo/logomark.png",
      favicon: "avo/favicon.ico",
      favicon_dark: "avo/favicon-dark.ico",
      chart_colors: %w[#0B8AE2 #34C683 #FFBE4F #FF7676 #2AB1EE #34C6A8 #EC8CFF #80FF91 #FFFC38 #1BDBE8],
      placeholder: "avo/placeholder.svg",
      neutrals: DEFAULT_NEUTRALS,
      accents: DEFAULT_ACCENTS,
      lock: [],
      picker_layout: :inline
    }.freeze
  end

  def initialize(options = {})
    config = DEFAULTS.merge(options)

    @scheme = config[:scheme]
    @neutral = config[:neutral]
    @accent = config[:accent]
    @neutral_colors = config[:neutral_colors]
    @accent_colors = config[:accent_colors]
    @main_content_background = config[:main_content_background]
    @neutrals = Array(config[:neutrals]).map(&:to_s).freeze
    @accents = Array(config[:accents]).map(&:to_s).freeze
    @lock = Array(config[:lock]).map(&:to_sym).freeze
    @persistence = config[:persistence]
    @logo = config[:logo]
    @logo_dark = config[:logo_dark]
    @logomark = config[:logomark]
    @logomark_dark = config[:logomark_dark]
    @favicon = config[:favicon]
    @favicon_dark = config[:favicon_dark]
    @chart_colors = config[:chart_colors]
    @placeholder = config[:placeholder]
    @picker_layout = config[:picker_layout]
    @load_settings_block = config[:load_settings]
    @save_settings_block = config[:save_settings]

    validate_picker_layout!(@picker_layout)
    validate_selection!("neutral", @neutral)
    validate_selection!("accent", @accent)
    validate_color_palette!("neutral_colors", @neutral_colors, NEUTRAL_SHADES, "shades") if @neutral_colors
    validate_color_palette!("accent_colors", @accent_colors, ACCENT_TOKENS, "tokens") if @accent_colors
  end

  def database_persistence? = persistence == :database

  def scheme_locked? = @lock.include?(:scheme)

  def neutral_locked? = @lock.include?(:neutral)

  def accent_locked? = @lock.include?(:accent)

  # Returns the neutral name for the data attribute (nil when neutral is unset)
  def neutral_css_class = neutral&.to_s

  # Returns the accent name for the data attribute (nil when accent is unset)
  def accent_css_class = accent&.to_s

  # Returns the inline CSS string that overrides appearance vars at :root when
  # any of neutral_colors / accent_colors / main_content_background are
  # configured. Despite the "brand" name this is the single appearance CSS
  # override pipeline, so it also emits non-brand layout vars like
  # --main-content-background. Returns nil when none are set so the layout can
  # skip emitting the <style> tag entirely.
  #
  # Brand palettes are single-toned — one set of values applied in both light
  # and dark mode (matching how the built-in `.neutral-theme-*` /
  # `.accent-theme-*` classes work). The override is emitted only in `:root`;
  # layer ordering does the rest.
  #
  # The output is wrapped in `@layer base` so it sits between Avo's defaults
  # (`@layer theme`, where the built-in `:root` colors and the `.dark`
  # overrides live) and the theme classes (`@layer components`, where
  # `.neutral-theme-*` / `.accent-theme-*` are defined).
  # Layer ordering — `theme < base < components` — guarantees:
  #   * Our :root override beats Avo's default `:root` palette and `.dark`
  #     overrides (we're in a later layer), so the brand color applies in
  #     both light and dark mode.
  #   * A user-selected `.accent-theme-orange` still wins over our `:root`
  #     (it's in a later layer), so the picker keeps working.
  # Without an `@layer` wrapper, the unlayered inline style would beat every
  # layered rule regardless of specificity, silently breaking theme selection.
  def brand_css_overrides
    return nil if neutral_colors.nil? && accent_colors.nil? && main_content_background.blank?

    [
      "@layer base {",
      "  :root {",
      *brand_declarations.map { |line| "  #{line}" },
      "  }",
      "}"
    ].join("\n")
  end

  private

  def brand_declarations
    declarations = []

    if neutral_colors
      NEUTRAL_SHADES.each do |shade|
        declarations << "  --color-avo-neutral-#{shade}: #{neutral_colors[shade]};"
      end
      # Brand-scoped alias for the picker swatch. Theme classes (`.neutral-theme-*`)
      # never set this var, so the swatch keeps showing the configured brand
      # neutral even while another theme is hovered or selected.
      declarations << "  --color-brand-neutral-400: #{neutral_colors[400]};"
    end

    if accent_colors
      ACCENT_TOKENS.each do |token|
        declarations << "  #{ACCENT_TOKEN_VAR_NAMES[token]}: #{accent_colors[token]};"
      end
      # Brand-scoped alias for the picker swatch. Theme classes (`.accent-theme-*`)
      # never set this var, so the swatch keeps showing the configured brand
      # accent even while another accent is hovered or selected.
      declarations << "  --color-brand-accent: #{accent_colors[:color]};"
    end

    if main_content_background.present?
      # Consumed by `.main-content { background: var(--main-content-background, ...) }`.
      # Accepts any CSS background value (url(), gradient, color, or shorthand).
      # Blank is treated as unset so we never emit an empty declaration.
      declarations << "  --main-content-background: #{main_content_background};"
    end

    declarations
  end

  def validate_picker_layout!(value)
    return if PICKER_LAYOUTS.include?(value)

    raise ArgumentError, "appearance.picker_layout must be one of #{PICKER_LAYOUTS.inspect}, got #{value.inspect}"
  end

  def validate_selection!(name, value)
    return if value.nil? || value.is_a?(Symbol)

    if value.is_a?(Hash)
      raise ArgumentError, "appearance.#{name} accepts a Symbol (default theme selection). " \
        "To override brand colors, use `#{name}_colors:` instead."
    end

    raise ArgumentError, "appearance.#{name} must be a Symbol, got #{value.class}"
  end

  def validate_color_palette!(name, palette, required_keys, missing_label)
    unless palette.is_a?(Hash)
      raise ArgumentError, "#{name} must be a Hash, got #{palette.class}"
    end

    missing = required_keys.select { |key| palette[key].nil? }
    raise ArgumentError, "#{name} is missing #{missing_label} #{missing.inspect}" if missing.any?
  end
end
