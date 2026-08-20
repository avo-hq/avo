# frozen_string_literal: true

require "rails_helper"

# Avo's maps have to render for someone who has never heard of Mapbox, and they
# have to keep their markers when the color scheme flips.
RSpec.describe "Map styles", type: :system do
  let!(:city) { create :city, latitude: 48.8584, longitude: 2.2945, name: "Paris" }

  # Local stand-ins for the OpenFreeMap pair, so the suite doesn't reach the
  # public internet to prove a swap works. Each is a bare background layer, and
  # its color is how we tell which one the map has loaded — the real pair is
  # indistinguishable by name and sprite, which is why the controller tracks
  # what it applied instead of sniffing the map.
  let(:backgrounds) { {light: "rgb(242,243,240)", dark: "rgb(12,12,12)"} }

  before do
    allow(Avo::MapStyles).to receive(:default).and_return(
      light: "/map_styles/light.json",
      dark: "/map_styles/dark.json"
    )
  end

  def map_state
    page.evaluate_script(<<~JS)
      (() => {
        const map = Object.values(window.Mapkick?.maps || {})[0]?.map
        // `getStyle()` throws mid-load, which is most of what we're waiting on.
        if (!map?.isStyleLoaded()) return null

        return {
          background: map.getPaintProperty("background", "background-color"),
          // Mapkick's markers live in a GeoJSON source named "objects". A style
          // swap wipes every source, so these layers are what the dark-mode
          // controller has to put back.
          markerLayers: map.getStyle().layers.filter((l) => l.source === "objects").length,
        }
      })()
    JS
  end

  # A timeout here is a real failure, so leave enough behind to tell which half
  # broke: the swap, or the restore that puts the markers back.
  def debug_dump
    page.evaluate_script(<<~JS)
      (() => {
        const map = Object.values(window.Mapkick?.maps || {})[0]?.map
        const loaded = !!map?.isStyleLoaded()
        return JSON.stringify({
          htmlClass: document.documentElement.className,
          styleLoaded: loaded,
          background: loaded ? map.getPaintProperty("background", "background-color") : null,
          layers: loaded ? map.getStyle().layers.map((l) => l.id) : null,
        })
      })()
    JS
  end

  def wait_for_map(theme)
    Timeout.timeout(20) do
      loop do
        state = map_state
        break state if state && state["background"] == backgrounds[theme] && state["markerLayers"].positive?

        sleep 0.2
      end
    end
  rescue Timeout::Error
    raise "timed out waiting for #{theme}: #{debug_dump}"
  end

  def set_theme(theme)
    page.execute_script("document.documentElement.classList.#{(theme == :dark) ? "add" : "remove"}('dark')")
  end

  it "renders without a Mapbox token and keeps its markers across theme swaps" do
    visit "/admin/resources/cities?view_type=map"
    expect(page).to have_css("canvas.mapboxgl-canvas")

    set_theme(:light)
    expect(wait_for_map(:light)["markerLayers"]).to be_positive

    set_theme(:dark)
    expect(wait_for_map(:dark)["markerLayers"]).to be_positive

    set_theme(:light)
    expect(wait_for_map(:light)["markerLayers"]).to be_positive

    expect(
      page.evaluate_script("performance.getEntriesByType('resource').filter((r) => r.name.includes('mapbox.com')).length")
    ).to eq 0
  end
end
