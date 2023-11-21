require "rails_helper"

RSpec.feature "RecursiveResources", type: :system do
  let!(:person) { create :person }
  let!(:spouse) { create :spouse, person: person }

  it "allows for recursive resources" do
    visit "/admin/resources/people/#{person.id}"

    wait_for_loaded

    within "turbo-frame#has_many_field_show_spouses" do
      expect(page).to have_text "Spouses"
      expect(page).to have_text spouse.name

      click_on spouse.id.to_s
    end

    wait_for_loaded

    expect(page).to have_current_path(avo.resources_spouse_path(spouse, via_resource_class: "Avo::Resources::Person", via_record_id: person.id))
  end
end
