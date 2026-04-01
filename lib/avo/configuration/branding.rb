class Avo::Configuration::Branding
  attr_accessor :mode, # :static | :dynamic
    :default_scheme, # :auto | :light | :dark
    :neutral, # Symbol | Hash (static mode only)
    :accent, # Symbol | Hash (static mode only)
    :persistence, # :localstorage | :database
    :logo,
    :logo_dark,
    :logomark,
    :logomark_dark,
    :favicon,
    :favicon_dark,
    :chart_colors,
    :placeholder

  # Stored blocks for database persistence
  attr_reader :load_settings_block, :save_settings_block

  def initialize
    @mode = :static
    @default_scheme = :auto
    @persistence = :localstorage
    @logo = "avo/logo.png"
    @logomark = "avo/logomark.png"
    @favicon = "avo/favicon.ico"
    @chart_colors = %w[#0B8AE2 #34C683 #FFBE4F #FF7676 #2AB1EE #34C6A8 #EC8CFF #80FF91 #FFFC38 #1BDBE8]
    @placeholder = "avo/placeholder.svg"
  end

  def load_settings(&block) = @load_settings_block = block
  def save_settings(&block) = @save_settings_block = block

  def static? = mode == :static
  def dynamic? = mode == :dynamic
  def database_persistence? = persistence == :database

  # Returns CSS class name for named symbol neutrals
  def neutral_css_class = neutral.is_a?(Symbol) ? "theme-#{neutral}" : nil

  # Returns inline :root CSS vars string for custom hash neutrals
  # Handles flat hash { 25 => value } or { light: {...}, dark: {...} }
  def neutral_css_vars(scheme: :light)
    return nil unless neutral.is_a?(Hash)

    scale = neutral.key?(:light) ? neutral[scheme] : neutral
    scale.map { |shade, value| "--color-avo-neutral-#{shade}: #{value};" }.join("\n")
  end

  # Returns CSS class name for named symbol accent
  def accent_css_class = accent.is_a?(Symbol) ? "accent-#{accent}" : nil

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
