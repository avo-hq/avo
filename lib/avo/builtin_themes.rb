module Avo
  # The themes core ships. Paper is Avo's stock look given a name; the next four
  # are Avo's own; the remaining eight are editor palettes reused under their
  # licenses (see NOTICE). Their stylesheets live together in
  # app/assets/stylesheets/avo/themes.css, which the layout links in the theme
  # slot, so `stylesheet` is nil on every one of them.
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
      self.description = "Avo's stock look: warm white surfaces, ink text."
    end

    class Coastal < Base
      self.title = "Coastal"
      self.description = "Sand neutrals, sea-glass and deep-ocean accents."
    end

    class Rose < Base
      self.title = "Rose"
      self.description = "Warm blush neutrals, rich rose accent."
    end

    class Sunset < Base
      self.title = "Sunset"
      self.description = "Dusk purples, magenta-to-orange accents."
    end

    class Midnight < Base
      self.title = "Midnight"
      self.description = "Cool near-black surfaces, electric indigo accent."
    end

    class Monokai < Base
      self.title = "Monokai"
      self.description = "Charcoal ground; yellow, magenta, cyan, green accents."
      self.attribution = "Monokai palette by Wimer Hazenberg (2006)."
    end

    class Dracula < Base
      self.title = "Dracula"
      self.description = "Purple-grey ground, pink and purple accents."
      self.attribution = "Dracula theme by Zeno Rocha, MIT."
    end

    class Solarized < Base
      self.title = "Solarized"
      self.description = "One sixteen-color palette, light and dark."
      self.attribution = "Solarized by Ethan Schoonover, MIT."
    end

    class Nord < Base
      self.title = "Nord"
      self.description = "Arctic blue-grey ground, frost accents."
      self.attribution = "Nord by Sven Greb, MIT."
    end

    class Gruvbox < Base
      self.title = "Gruvbox"
      self.description = "Retro warm browns and olive, orange accent."
      self.attribution = "Gruvbox by Pavel Pertsev, MIT."
    end

    class OneDark < Base
      self.title = "One Dark"
      self.description = "Blue-grey ground, blue and purple accents."
      self.attribution = "One Dark / One Light by the Atom team, MIT."
    end

    class Catppuccin < Base
      self.title = "Catppuccin"
      self.description = "Pastel palette: Latte by day, Mocha by night."
      self.attribution = "Catppuccin by the Catppuccin organization, MIT."
    end

    class TokyoNight < Base
      self.title = "Tokyo Night"
      self.description = "Deep navy, soft purple and cyan accents."
      self.attribution = "Tokyo Night by Enrico Kaiser (enkia), MIT."
    end

    ALL = [Paper, Coastal, Rose, Sunset, Midnight, Monokai, Dracula, Solarized, Nord, Gruvbox, OneDark, Catppuccin, TokyoNight].freeze unless defined?(ALL)

    def self.all = ALL

    def self.ids = ALL.map(&:id)
  end
end
