# frozen_string_literal: true

require "rails_helper"

# The point of the whole thing: a fresh install with no Mapbox account must not
# be handed a `mapbox://` URL, because those render a blank map without a token.
RSpec.describe Avo::MapStyles do
  around do |example|
    original = ENV["MAPBOX_ACCESS_TOKEN"]
    ENV["MAPBOX_ACCESS_TOKEN"] = nil
    example.run
  ensure
    ENV["MAPBOX_ACCESS_TOKEN"] = original
  end

  describe ".default" do
    it "falls back to OpenFreeMap when there is no Mapbox token" do
      expect(described_class.default).to eq described_class.open_free_map
      expect(described_class.default.values).to all(start_with("https://tiles.openfreemap.org/"))
    end

    it "keeps Mapbox for anyone who has a token" do
      ENV["MAPBOX_ACCESS_TOKEN"] = "pk.test"

      expect(described_class.default).to eq described_class.mapbox
    end
  end

  describe "config.map_view" do
    around do |example|
      original = Avo.configuration.map_view
      example.run
    ensure
      Avo.configuration.map_view = original
    end

    it "defaults to leaving the choice to the environment" do
      expect(Avo.configuration.map_view).to eq(styles: nil)
      expect(described_class.default).to eq described_class.open_free_map
    end

    it "forces a provider by name, token or no token" do
      Avo.configuration.map_view = {styles: :mapbox}
      expect(described_class.default).to eq described_class.mapbox

      ENV["MAPBOX_ACCESS_TOKEN"] = "pk.test"
      Avo.configuration.map_view = {styles: :open_free_map}
      expect(described_class.default).to eq described_class.open_free_map
    end

    it "takes a custom pair" do
      pair = {light: "https://example.com/light.json", dark: "https://example.com/dark.json"}
      Avo.configuration.map_view = {styles: pair}

      expect(described_class.default).to eq pair
      expect(described_class.light).to eq pair[:light]
    end
  end

  describe "the map surfaces" do
    let(:custom) { "https://tiles.openfreemap.org/styles/liberty" }

    def map_view_style(**mapkick_options)
      resource = Avo::Resources::City.new
      resource.map_view = resource.map_view.merge(mapkick_options: mapkick_options)

      Avo::Index::ResourceMapComponent.new(resource: resource, resources: []).resource_mapkick_options[:style]
    end

    def location_style(**args)
      Avo::Fields::LocationField.new(:coordinates, **args).default_mapkick_options(false)[:style]
    end

    def area_style(**args)
      Avo::Fields::AreaField.new(:city_center_area, **args).mapkick_options[:style]
    end

    it "defaults every interactive map to a keyless style" do
      expect(map_view_style).to eq described_class.open_free_map[:light]
      expect(location_style).to eq described_class.open_free_map[:light]
      expect(area_style).to eq described_class.open_free_map[:light]
    end

    it "lets a resource override the style" do
      expect(map_view_style(style: custom)).to eq custom
      expect(location_style(mapkick_options: {style: custom})).to eq custom
      expect(area_style(mapkick_options: {style: custom})).to eq custom
    end

    it "does not leak the resolved style back into the resource's own config" do
      resource = Avo::Resources::City.new
      Avo::Index::ResourceMapComponent.new(resource: resource, resources: []).resource_mapkick_options

      expect(resource.map_view[:mapkick_options]).not_to have_key(:style)
    end
  end
end
