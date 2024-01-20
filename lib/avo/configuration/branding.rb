class Avo::Configuration::Branding
  def initialize(colors: nil, chart_colors: nil, logo: nil, logomark: nil, placeholder: nil, favicon: nil)
    @colors = colors || {}
    @chart_colors = chart_colors
    @logo = logo
    @logomark = logomark
    @placeholder = placeholder
    @favicon = favicon

    @default_colors = {
      background: "#F6F6F7",
      100 => "206 231 248",
      400 => "57 158 229",
      500 => "8 134 222",
      600 => "6 107 178"
    }
    # We're using same default colors as the Chartkick gem
    # which is based on this list:
    # http://there4.io/2012/05/02/google-chart-color-list/
    @default_chart_colors = [
      "#3366CC", "#DC3912", "#FF9900", "#109618", "#990099", "#3B3EAC", "#0099C6",
      "#DD4477", "#66AA00", "#B82E2E", "#316395", "#994499", "#22AA99", "#AAAA11",
      "#6633CC", "#E67300", "#8B0707", "#329262", "#5574A6", "#651067"
    ];
    @default_logo = "/avo-assets/logo.png"
    @default_logomark = "/avo-assets/logomark.png"
    @default_placeholder = "/avo-assets/placeholder.svg"
    @default_favicon = "/avo-assets/favicon.ico"
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
    @logo || @default_logo
  end

  def logomark
    @logomark || @default_logomark
  end

  def placeholder
    @placeholder || @default_placeholder
  end

  def chart_colors
    @chart_colors || @default_chart_colors
  end

  def favicon
    @favicon || @default_favicon
  end

  private

  def colors
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
