require 'rails_helper'

RSpec.feature "Select", type: :feature do
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

  # Go to line xpto to see the hash and the test cases
  describe "when options are a hash" do
    context "simple" do
      it "show key but save value" do
        CityResource.with_temporary_items do
          field :population, as: :select, options: HASH_OPTIONS
        end
        test_hash
        CityResource.restore_items_from_backup
      end

      it "show value and save value (display_value true)" do
        CityResource.with_temporary_items do
          field :population, as: :select, options: HASH_OPTIONS, display_value: true
        end
        test_hash_display_value
        CityResource.restore_items_from_backup
      end
    end

    context "inside block" do
      it "show key but save value" do
        CityResource.with_temporary_items do
          field :population, as: :select, options: ->(model:, resource:, view:, field:) do
            HASH_OPTIONS
          end
        end
        test_hash
        CityResource.restore_items_from_backup
      end

      it "show value and save value (display_value true)" do
        CityResource.with_temporary_items do
          field :population, as: :select, display_value: true, options: ->(model:, resource:, view:, field:) do
            HASH_OPTIONS
          end
        end
        test_hash_display_value
        CityResource.restore_items_from_backup
      end
    end
  end

  describe "when options are an array" do
    context "simple" do
      it "show and save the value" do
        CityResource.with_temporary_items do
          field :name, as: :select, options: ->(model:, resource:, view:, field:) do
            ARRAY_OPTIONS
          end
        end
        test_array
        CityResource.restore_items_from_backup
      end

      it "normal behaviour with display_value" do
        CityResource.with_temporary_items do
          field :name, as: :select, display_value: true, options: ->(model:, resource:, view:, field:) do
            ARRAY_OPTIONS
          end
        end
        test_array
        CityResource.restore_items_from_backup
      end
    end

    context "inside block" do
      it "show and save the value" do
        CityResource.with_temporary_items do
          field :name, as: :select, options: ARRAY_OPTIONS
        end
        test_array
        CityResource.restore_items_from_backup
      end

      it "normal behaviour with display_value" do
        CityResource.with_temporary_items do
          field :name, as: :select, options: ARRAY_OPTIONS, display_value: true
        end
        test_array
        CityResource.restore_items_from_backup
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

HASH_OPTIONS = {
  'Zero': 0,
  'Low': 50000,
  'Medium': 100000,
  'High': 250000,
}

def test_hash
  visit avo.new_resources_city_path
  expect(page).to have_select "city_population", selected: nil, options: ["Zero", "Low", "Medium", "High"]
  select "Medium", from: "city_population"
  save
  expect(page).to have_text "Medium"
  expect(City.last.population).to eq 100000
end

def test_hash_display_value
  visit avo.new_resources_city_path
  expect(page).to have_select "city_population", selected: nil, options: ["0", "50000", "100000", "250000"]
  select "250000", from: "city_population"
  save
  expect(page).to have_text "250000"
  expect(City.last.population).to eq 250000
end

ARRAY_OPTIONS =  ["Baia Mare", "București", "Coimbra", "Porto"]

def test_array
  visit avo.new_resources_city_path
  expect(page).to have_select "city_name", selected: nil, options: ["Baia Mare", "București", "Coimbra", "Porto"]
  select "București", from: "city_name"
  save
  expect(page).to have_text "București"
  expect(City.last.name).to eq "București"
end
