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

  describe "when options hash" do
    context "create and show" do
      it "show key but save value" do
        CityResource.with_temporary_items do
          field :population, as: :select, options: {
            'Zero': 0,
            'Low': 50000,
            'Medium': 100000,
            'High': 250000,
          }
        end

        visit avo.new_resources_city_path

        expect(page).to have_select "city_population", selected: nil, options: ["Zero", "Low", "Medium", "High"]

        select "Medium", from: "city_population"
        save
        expect(page).to have_text "Medium"
        expect(City.last.population).to eq 100000
      end
    end
  end

  describe "when options are enum array" do
    context "create and show" do
      it "show key but save value" do
        visit avo.new_resources_post_path

        expect(page).to have_select "post_status", selected: "draft", options: ["draft", "published", "archived"]

        fill_in "post_name", with: "Published post =)"
        select "published", from: "post_status"
        save
        expect(page).to have_text "published"
        expect(Post.last.status).to eq "published"
      end
    end
  end
end
