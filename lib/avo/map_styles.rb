# frozen_string_literal: true

module Avo
  # The light/dark style pair every Avo map defaults to.
  #
  # Mapbox stays the default for anyone who has a token. Without one its
  # `mapbox://` URLs render a blank map, which is why a fresh Avo install used to
  # need a Mapbox signup before it could show a map at all — so fall back to
  # OpenFreeMap: no key, no registration, no request cap, commercial use allowed.
  # Attribution rides along in the TileJSON, so the map's own attribution control
  # credits OpenFreeMap/OpenMapTiles/OpenStreetMap with nothing extra to wire up.
  # https://openfreemap.org
  #
  # Force one either way with `config.map_view = {styles: :mapbox}` (or
  # `:open_free_map`), or give it your own `{light:, dark:}` pair.
  #
  # Override a single map with `mapkick_options: {style: "..."}`. That is one
  # style rather than a pair, so Avo leaves that map alone in dark mode.
  module MapStyles
    # Methods rather than constants: Avo's `lib` is walked by two autoloaders, so
    # a constant here is assigned twice and Ruby warns on every boot.
    class << self
      def mapbox
        {
          light: "mapbox://styles/mapbox/light-v11",
          dark: "mapbox://styles/mapbox/dark-v11"
        }.freeze
      end

      def open_free_map
        {
          light: "https://tiles.openfreemap.org/styles/positron",
          dark: "https://tiles.openfreemap.org/styles/dark"
        }.freeze
      end

      def default
        resolve(Avo.configuration.map_view[:styles]) || (mapbox_token? ? mapbox : open_free_map)
      end

      def light = default[:light]

      # Data attributes for the map wrapper. `map-dark-mode` swaps between the
      # two styles on theme change; without the pair it leaves the map alone,
      # which is what we want when the resource picked its own style.
      def wrapper_data(custom_style: nil)
        data = {controller: "map-dark-mode"}
        data[:map_dark_mode_styles_value] = default if custom_style.blank?
        data
      end

      private

      def resolve(setting)
        case setting
        when :mapbox then mapbox
        when :open_free_map then open_free_map
        when Hash then setting
        end
      end

      def mapbox_token? = ENV["MAPBOX_ACCESS_TOKEN"].present?
    end
  end
end
