module Avo
  # The themes core ships. Paper is Avo's stock look given a name and the one
  # theme that leaves the neutral, accent, and scheme pickers open; every other
  # built-in is a finished look drawn for one scheme. Where an editor palette
  # publishes both a light and a dark variant, each is its own theme, so the
  # picker says exactly what you get and no theme has to style a scheme it
  # was never designed for. Their stylesheets live together in
  # app/assets/stylesheets/avo/themes.css, which the layout links in the theme
  # slot, so `stylesheet` is nil on every one of them. Palette credits: NOTICE.
  #
  # They live under Avo::BuiltinThemes rather than Avo::Themes because the
  # latter is the host app's namespace (`app/avo/themes/`), and a core class
  # there would collide with a host theme of the same name.
  module BuiltinThemes
    class Base < Avo::BaseTheme
      abstract!
      self.stylesheet = nil

      def self.builtin? = true
    end

    class Paper < Base
      self.title = "Paper"
      self.description = "Avo's stock look. Pick your own neutral, accent, and scheme."
      self.lock = []
    end

    class Coastal < Base
      self.title = "Coastal"
      self.description = "Sand surfaces, a sand navbar, sea-glass accent."
    end

    class Rose < Base
      self.title = "Rose"
      self.description = "Warm blush neutrals, deep rose navbar, rich rose accent."
    end

    class Sunset < Base
      self.title = "Sunset"
      self.description = "Dusk purples, magenta accent, amber warnings."
    end

    class Midnight < Base
      self.title = "Midnight"
      self.description = "Cool near-black surfaces, electric indigo accent."
      self.scheme = :dark
    end

    class Monokai < Base
      self.title = "Monokai"
      self.description = "Charcoal ground; pink, yellow, cyan, green accents."
      self.scheme = :dark
      self.attribution = "Monokai palette by Wimer Hazenberg (2006)."
    end

    class Dracula < Base
      self.title = "Dracula"
      self.description = "Purple-grey ground, purple and pink accents."
      self.scheme = :dark
      self.attribution = "Dracula theme by Zeno Rocha, MIT."
    end

    class Nord < Base
      self.title = "Nord"
      self.description = "Arctic blue-grey ground, frost accents."
      self.scheme = :dark
      self.attribution = "Nord by Sven Greb, MIT."
    end

    class SolarizedLight < Base
      self.title = "Solarized Light"
      self.description = "Cream base3 surfaces, a cream navbar, blue accent."
      self.attribution = "Solarized by Ethan Schoonover, MIT."
    end

    class SolarizedDark < Base
      self.title = "Solarized Dark"
      self.description = "Base03 surfaces, blue accent, the same sixteen colors."
      self.scheme = :dark
      self.attribution = "Solarized by Ethan Schoonover, MIT."
    end

    class GruvboxLight < Base
      self.title = "Gruvbox Light"
      self.description = "Retro cream surfaces and a cream navbar, orange accent."
      self.attribution = "Gruvbox by Pavel Pertsev, MIT."
    end

    class GruvboxDark < Base
      self.title = "Gruvbox Dark"
      self.description = "Retro warm browns, orange accent."
      self.scheme = :dark
      self.attribution = "Gruvbox by Pavel Pertsev, MIT."
    end

    class OneLight < Base
      self.title = "One Light"
      self.description = "Cool grey surfaces, blue accent."
      self.attribution = "One Dark / One Light by the Atom team, MIT."
    end

    class OneDark < Base
      self.title = "One Dark"
      self.description = "Blue-grey ground, blue and purple accents."
      self.scheme = :dark
      self.attribution = "One Dark / One Light by the Atom team, MIT."
    end

    class CatppuccinLatte < Base
      self.title = "Catppuccin Latte"
      self.description = "Pastel latte surfaces and a latte navbar, mauve accent."
      self.attribution = "Catppuccin by the Catppuccin organization, MIT."
    end

    class CatppuccinMocha < Base
      self.title = "Catppuccin Mocha"
      self.description = "Pastel mocha ground, mauve accent."
      self.scheme = :dark
      self.attribution = "Catppuccin by the Catppuccin organization, MIT."
    end

    class TokyoNightDay < Base
      self.title = "Tokyo Night Day"
      self.description = "Soft blue-grey day surfaces, blue accent."
      self.attribution = "Tokyo Night by Enrico Kaiser (enkia), MIT."
    end

    class TokyoNight < Base
      self.title = "Tokyo Night"
      self.description = "Deep navy, soft blue and cyan accents."
      self.scheme = :dark
      self.attribution = "Tokyo Night by Enrico Kaiser (enkia), MIT."
    end

    unless defined?(ALL)
      ALL = [
        Paper, Coastal, Rose, Sunset, Midnight,
        Monokai, Dracula, Nord,
        SolarizedLight, SolarizedDark,
        GruvboxLight, GruvboxDark,
        OneLight, OneDark,
        CatppuccinLatte, CatppuccinMocha,
        TokyoNightDay, TokyoNight
      ].freeze
    end

    def self.all = ALL

    def self.ids = ALL.map(&:id)

    # The editor palettes: every built-in that carries a license credit.
    def self.editor_themes = ALL.select(&:attribution)
  end
end
