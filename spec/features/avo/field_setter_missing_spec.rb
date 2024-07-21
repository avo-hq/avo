require 'rails_helper'

RSpec.feature "FieldSetterMissings", type: :feature do
  let!(:person) { create :person }

  context "on index" do
    it "shows the field if the setter is missing" do
      visit "/admin/resources/people"

      expect(page).to have_css "[data-field-id='type']"
      expect(page).to have_css "[data-field-id='link']"
    end
  end

  context "on show" do
    it "shows the field if the setter is missing" do
      visit "/admin/resources/people/#{person.id}"

      expect(page).to have_css "[data-field-id='type']"
      expect(page).to have_css "[data-field-id='link']"
    end
  end

  context "on edit" do
    it "does not show the field if the setter is missing" do
      visit "/admin/resources/people/#{person.id}/edit"

      expect(page).to have_css "[data-field-id='type']"
      expect(page).not_to have_css "[data-field-id='link']"
    end
  end
end
