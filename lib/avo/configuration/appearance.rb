class Avo::Configuration::Appearance
  attr_reader :scheme, # :auto | :light | :dark
    :neutral, # Symbol — default theme selection (e.g. :slate, :brand)
    :accent,  # Symbol — default accent selection (e.g. :blue, :brand)
    :neutral_colors, # Hash{ light:, dark: } — full 12-shade brand override
    :accent_colors,  # Hash{ light:, dark: } — three-token brand override
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
    :load_settings_block,
    :save_settings_block

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
  SCHEMES = [:light, :dark].freeze

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
    lock: []
  }.freeze

  def initialize(options = {})
    config = DEFAULTS.merge(options)

    @scheme = config[:scheme]
    @neutral = config[:neutral]
    @accent = config[:accent]
    @neutral_colors = config[:neutral_colors]
    @accent_colors = config[:accent_colors]
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
    @load_settings_block = config[:load_settings]
    @save_settings_block = config[:save_settings]

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

  # Returns the full inline CSS string that overrides brand vars at :root and .dark
  # when neutral_colors / accent_colors are configured. Returns nil when neither is set
  # so the layout can skip emitting the <style> tag entirely.
  #
  # The output is wrapped in `@layer base` so it sits between Avo's defaults
  # (`@layer theme`, where the built-in `:root` colors live) and the theme classes
  # (`@layer components`, where `.neutral-theme-*` / `.accent-theme-*` are defined).
  # Layer ordering — `theme < base < components` — guarantees:
  #   * Our override beats Avo's default `:root` palette (we're in a later layer)
  #   * A user-selected `.accent-theme-orange` still wins over our `:root` (it's
  #     in a later layer), so the picker keeps working.
  # Without an `@layer` wrapper, the unlayered inline style would beat every
  # layered rule regardless of specificity, silently breaking theme selection.
  def brand_css_overrides
    return nil if neutral_colors.nil? && accent_colors.nil?

    [
      "@layer base {",
      "  :root {",
      *brand_declarations_for(:light).map { |line| "  #{line}" },
      "  }",
      "  .dark {",
      *brand_declarations_for(:dark).map { |line| "  #{line}" },
      "  }",
      "}"
    ].join("\n")
  end

  private

  def brand_declarations_for(scheme)
    declarations = []

    if neutral_colors
      NEUTRAL_SHADES.each do |shade|
        declarations << "  --color-avo-neutral-#{shade}: #{neutral_colors[scheme][shade]};"
      end
      # Brand-scoped alias for the picker swatch. Theme classes (`.neutral-theme-*`)
      # never set this var, so the swatch keeps showing the configured brand
      # neutral even while another theme is hovered or selected.
      declarations << "  --color-brand-neutral-400: #{neutral_colors[scheme][400]};"
    end

    if accent_colors
      ACCENT_TOKENS.each do |token|
        declarations << "  #{ACCENT_TOKEN_VAR_NAMES[token]}: #{accent_colors[scheme][token]};"
      end
      # Brand-scoped alias for the picker swatch. Theme classes (`.accent-theme-*`)
      # never set this var, so the swatch keeps showing the configured brand
      # accent even while another accent is hovered or selected.
      declarations << "  --color-brand-accent: #{accent_colors[scheme][:color]};"
    end

    declarations
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
      raise ArgumentError, "#{name} must be a Hash with :light and :dark keys, got #{palette.class}"
    end

    errors = []
    SCHEMES.each do |scheme|
      scheme_hash = palette[scheme]
      if scheme_hash.nil?
        errors << "missing scheme :#{scheme}"
        next
      end
      unless scheme_hash.is_a?(Hash)
        errors << ":#{scheme} must be a Hash, got #{scheme_hash.class}"
        next
      end
      missing = required_keys.select { |key| scheme_hash[key].nil? }
      errors << ":#{scheme} missing #{missing_label} #{missing.inspect}" if missing.any?
    end

    raise ArgumentError, "#{name} is invalid: #{errors.join("; ")}" if errors.any?
  end
end
