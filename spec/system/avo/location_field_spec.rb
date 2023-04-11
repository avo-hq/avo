# frozen_string_literal: true

require "rails_helper"

RSpec.describe "LocationField", type: :system do
  describe "without value" do
    let(:city) { create :city, coordinates: [] }

    context "show" do
      it "shows empty location field" do
        visit "/admin/resources/cities/#{city.id}"

        expect(find_field_element("coordinates")).to have_text empty_dash
      end
    end

    context "edit" do
      it "has lat/long fields and placeholders" do
        visit "/admin/resources/cities/#{city.id}/edit"

        coordinates_element = find_field_element("coordinates")

        expect(coordinates_element).to have_text "COORDINATES"

        expect(find_by_id("city_coordinates[latitude]", visible: false)).to have_text("")
        expect(find_by_id("city_coordinates[latitude]", visible: false)[:placeholder]).to have_text("Enter latitude")

        expect(find_by_id("city_coordinates[longitude]", visible: false)).to have_text("")
        expect(find_by_id("city_coordinates[longitude]", visible: false)[:placeholder]).to have_text("Enter longitude")
      end

      it "changes the city coordinates" do
        visit "/admin/resources/cities/#{city.id}/edit"

        fill_in "Enter latitude", with: "1.0"
        fill_in "Enter longitude", with: "2.0"

        click_on "Save"

        wait_for_loaded

        click_on "Edit"

        expect(find_by_id("city_coordinates[latitude]").value).to eq("1.0")
        expect(find_by_id("city_coordinates[longitude]").value).to eq("2.0")
      end
    end
  end

  describe "with regular value" do
    # Eiffel Tower coordinates used
    let!(:city) { create :city, latitude: 48.8584, longitude: 2.2945 }

    context "show" do
      it "renders a map" do
        Avo::Fields::LocationField::ShowComponent.any_instance.stub(:js_map).and_return("map_content_here")
        visit "/admin/resources/cities/#{city.id}"

        expect(page).to have_text("map_content_here")
      end
    end

    context "edit" do
      it "has filled lat/long values in editor" do
        visit "/admin/resources/cities/#{city.id}/edit"

        expect(find_by_id("city_coordinates[latitude]").value).to eq("48.8584")
        expect(find_by_id("city_coordinates[longitude]").value).to eq("2.2945")
      end
    end
  end
end
