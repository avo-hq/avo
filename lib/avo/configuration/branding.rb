class Avo::Configuration::Branding
  def initialize(colors: nil, logo: nil, logomark: nil)
    @colors = colors
    @logo = logo
    @logomark = logomark

    @default_colors = {
      100 => "206 231 248",
      400 => "57 158 229",
      500 => "8 134 222",
      600 => "6 107 178"
    }
    @default_logo = "/avo-assets/logo.png"
    @default_logomark = "/avo-assets/logomark.png"
  end

  def css_colors
    rgb_colors.map do |color, value|
      "--color-primary-#{color}: #{value};"
    end.join("\n")
  end

  def logo
    return @default_logo if Avo::App.license.lacks_with_trial(:branding)

    @logo || @default_logo
  end

  def logomark
    return @default_logomark if Avo::App.license.lacks_with_trial(:branding)

    @logomark || @default_logomark
  end

  private

  def colors
    return @default_colors if Avo::App.license.lacks_with_trial(:branding)

    @colors || @default_colors
  end

  def rgb_colors
    colors.map do |key, value|
      rgb_value = is_hex?(value) ? hex_to_rgb(value) : value
      [key, rgb_value]
    end.to_h
  end

  def is_hex?(value)
    value.include? "#"
  end

  def hex_to_rgb(value)
    value.to_s.match(/^#(..)(..)(..)$/).captures.map(&:hex).join(" ")
  end
end
