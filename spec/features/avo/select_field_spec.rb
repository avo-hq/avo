require 'rails_helper'

RSpec.feature "Selects", type: :feature do
  let(:project) { create :project }
  let(:placeholder) { "Choose an option" }

  describe "when type is nil" do
    let(:person) { create :person, type: nil }

    context "edit" do
      it "shows the placeholder" do
        visit avo.edit_resources_person_path person

        expect(page).to have_select "person_type", selected: nil, options: [placeholder, "Spouse", "Sibling"]
      end
    end

    context "new" do
      it "shows the placeholder" do
        visit avo.new_resources_person_path

        expect(page).to have_select "person_type", selected: nil, options: [placeholder, "Spouse", "Sibling"]
      end
    end
  end

  describe "when type is selected" do
    let(:person) { create :person, type: "Spouse" }

    context "edit" do
      it "shows the placeholder" do
        visit avo.edit_resources_person_path person

        expect(page).to have_select "person_type", selected: "Spouse", options: [placeholder, "Spouse", "Sibling"]
      end
    end
  end
end
