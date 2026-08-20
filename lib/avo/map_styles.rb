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
  # Override a single map with `mapkick_options: {style: "..."}`.
  module MapStyles
    # Methods rather than constants, mirroring Avo 4: there `lib` is walked by two
    # autoloaders and a constant here would be assigned twice on every boot.
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

      # Avo 3 renders maps in one theme; `dark` is here so a `{light:, dark:}`
      # pair configured on 3 keeps working on 4, which swaps between them.
      def light = default[:light]

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
