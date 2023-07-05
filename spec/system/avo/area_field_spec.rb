# frozen_string_literal: true

require "rails_helper"

RSpec.describe "AreaField", type: :system do
  describe "without value" do
    let(:city) { create :city, city_center_area: nil }

    context "show" do
      it "shows empty area field" do
        visit "/admin/resources/cities/#{city.id}"

        expect(find_field_element("city_center_area")).to have_text empty_dash
      end
    end

    context "edit" do
      it "has area field" do
        visit "/admin/resources/cities/#{city.id}/edit"

        area_element = find_field_element("city_center_area")

        expect(area_element).to have_text "CITY CENTER AREA"
      end

      it "changes the city center area" do
        visit "/admin/resources/cities/#{city.id}/edit"

        fill_in "city_city_center_area", with: "[[[2.312955267531237, 48.88063965390646], [2.312955267531237, 48.831194952976006], [2.3842221159307257, 48.831194952976006], [2.3842221159307257, 48.88063965390646], [2.312955267531237, 48.88063965390646]]]"

        click_on "Save"

        wait_for_loaded

        click_on "Edit"

        expect(find_by_id("city_city_center_area").value).to eq("[[[2.312955267531237, 48.88063965390646], [2.312955267531237, 48.831194952976006], [2.3842221159307257, 48.831194952976006], [2.3842221159307257, 48.88063965390646], [2.312955267531237, 48.88063965390646]]]")
      end
    end
  end

  describe "with regular value" do
    let!(:city) { create :city, city_center_area: [[[2.312955267531237, 48.88063965390646], [2.312955267531237, 48.831194952976006], [2.3842221159307257, 48.831194952976006], [2.3842221159307257, 48.88063965390646], [2.312955267531237, 48.88063965390646]]].to_json }

    context "show" do
      it "renders a map" do
        expect_any_instance_of(Avo::Fields::AreaField::ShowComponent).to receive(:area_map).and_return("map_content_here")
        visit "/admin/resources/cities/#{city.id}"

        expect(page).to have_text("map_content_here")
      end
    end

    context "edit" do
      it "has filled city_center_area values in editor" do
        visit "/admin/resources/cities/#{city.id}/edit"

        expect(find_by_id("city_city_center_area").value).to eq("[[[2.312955267531237,48.88063965390646],[2.312955267531237,48.831194952976006],[2.3842221159307257,48.831194952976006],[2.3842221159307257,48.88063965390646],[2.312955267531237,48.88063965390646]]]")
      end
    end
  end
end
