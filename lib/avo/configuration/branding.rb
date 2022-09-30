class Avo::Configuration::Branding
  def initialize(colors: nil, chart_colors: nil, logo: nil, logomark: nil, placeholder: nil)
    @colors = colors || {}
    @chart_colors = chart_colors
    @logo = logo
    @logomark = logomark
    @placeholder = placeholder

    @default_colors = {
      background: "#F6F6F7",
      100 => "206 231 248",
      400 => "57 158 229",
      500 => "8 134 222",
      600 => "6 107 178"
    }
    @default_chart_colors = ["#0B8AE2", "#34C683", "#2AB1EE", "#34C6A8"]
    @default_logo = "/avo-assets/logo.png"
    @default_logomark = "/avo-assets/logomark.png"
    @default_placeholder = "placeholder.svg"
  end

  def css_colors
    rgb_colors.map do |color, value|
      if color == :background
        "--color-application-#{color}: #{value};"
      else
        "--color-primary-#{color}: #{value};"
      end
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

  def placeholder
    return @default_placeholder if Avo::App.license.lacks_with_trial(:branding)

    @placeholder || @default_placeholder
  end

  def chart_colors
    return @default_chart_colors if Avo::App.license.lacks_with_trial(:branding)

    @chart_colors || @default_chart_colors
  end

  private

  def colors
    return @default_colors if Avo::App.license.lacks_with_trial(:branding)

    @default_colors.merge(@colors) || @default_colors
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
