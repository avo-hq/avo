class Avo::Configuration::Branding
  attr_reader :mode, # :static | :dynamic
    :scheme, # :auto | :light | :dark
    :neutral, # Symbol | Hash
    :accent, # Symbol | Hash
    :persistence, # :localstorage | :database
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

  DEFAULTS = {
    mode: :static,
    scheme: :auto,
    persistence: :localstorage,
    logo: "avo/logo.png",
    logomark: "avo/logomark.png",
    favicon: "avo/favicon.ico",
    chart_colors: %w[#0B8AE2 #34C683 #FFBE4F #FF7676 #2AB1EE #34C6A8 #EC8CFF #80FF91 #FFFC38 #1BDBE8],
    placeholder: "avo/placeholder.svg"
  }.freeze

  def initialize(options = {})
    config = DEFAULTS.merge(options)

    @mode = config[:mode]
    @scheme = config[:scheme]
    @neutral = config[:neutral]
    @accent = config[:accent]
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

    # Track which options were explicitly provided so we can lock them in static mode
    @explicitly_set = %i[scheme neutral accent].select { |key| options.key?(key) }
  end

  def static? = mode == :static
  def dynamic? = mode == :dynamic
  def database_persistence? = persistence == :database

  # In static mode, explicitly set values are locked (user can't change them).
  # In dynamic mode, they're just defaults — never locked.
  def scheme_locked? = static? && @explicitly_set.include?(:scheme)
  def neutral_locked? = static? && @explicitly_set.include?(:neutral)
  def accent_locked? = static? && @explicitly_set.include?(:accent)

  # Returns the neutral name for the data attribute
  def neutral_css_class = neutral.is_a?(Symbol) ? neutral.to_s : nil

  # Returns inline :root CSS vars string for custom hash neutrals
  # Handles flat hash { 25 => value } or { light: {...}, dark: {...} }
  def neutral_css_vars(scheme: :light)
    return nil unless neutral.is_a?(Hash)

    scale = neutral.key?(:light) ? neutral[scheme] : neutral
    scale.map { |shade, value| "--color-avo-neutral-#{shade}: #{value};" }.join("\n")
  end

  # Returns the accent name for the data attribute
  def accent_css_class = accent.is_a?(Symbol) ? accent.to_s : nil

  # Returns inline CSS vars for custom hash accent
  def accent_css_vars(scheme: :light)
    return nil unless accent.is_a?(Hash)

    tokens = accent.key?(:light) ? accent[scheme] : accent
    [
      "--color-accent: #{tokens[:color]};",
      "--color-accent-content: #{tokens[:content]};",
      "--color-accent-foreground: #{tokens[:foreground]};"
    ].join("\n")
  end

  # Future: effective_mode for license gating
  def effective_mode = mode
end
