class Avo::Configuration::Branding
  attr_reader :scheme, # :auto | :light | :dark
    :neutral, # Symbol | Hash
    :accent, # Symbol | Hash
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

  DEFAULT_NEUTRALS = %w[slate stone gray zinc neutral taupe mauve mist olive].freeze
  DEFAULT_ACCENTS = %w[red orange amber yellow lime green emerald teal cyan sky blue indigo violet purple fuchsia pink rose].freeze
  LOCKABLE = %i[scheme neutral accent].freeze

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
  end

  def database_persistence? = persistence == :database

  def scheme_locked? = @lock.include?(:scheme)

  def neutral_locked? = @lock.include?(:neutral)

  def accent_locked? = @lock.include?(:accent)

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
end
