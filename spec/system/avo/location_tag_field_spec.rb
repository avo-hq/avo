# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'LocationTagField', type: :system do
  describe 'without value' do
    let(:city) { create :city, coordinates: [] }
    context 'show' do
      it 'shows empty location field' do
        visit "/admin/resources/cities/#{city.id}"

        expect(find_field_element('coordinates')).to have_text empty_dash
      end
    end
    context 'edit' do
      it "has a field for latitude and longitude" do
      it "has lat/long fields and placeholders" do
        visit "/admin/resources/cities/#{city.id}/edit"

        coordinates_element = find_field_element("coordinates")

        expect(coordinates_element).to have_text "COORDINATES"

        expect(find_by_id("city_coordinates[latitude]", visible: false)).to have_text("")
        expect(find_by_id("city_coordinates[latitude]", visible: false)[:placeholder]).to have_text("Enter latitude")

        expect(find_by_id("city_coordinates[longitude]", visible: false)).to have_text("")
        expect(find_by_id("city_coordinates[longitude]", visible: false)[:placeholder]).to have_text("Enter longitude")
      end
    end
  end

  describe 'with regular value' do
  end
end

def fill_in_trix_editor(id, with:)
  find("trix-editor[input='#{id}']").click.set(with)
end
