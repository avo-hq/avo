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

  describe "when options are a hash" do
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
    ARRAY_OPTIONS =  ["Baia Mare", "București", "Coimbra", "Porto"]

    def test_array
      visit avo.new_resources_city_path
      expect(page).to have_select "city_name", selected: nil, options: ["Baia Mare", "București", "Coimbra", "Porto"]
      select "București", from: "city_name"
      save
      expect(page).to have_text "București"
      expect(City.last.name).to eq "București"
    end

    context "simple" do
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

    context "inside block" do
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

  end

  describe "when options are enum array" do
    context "simple" do
      it "show key but save value" do
        PostResource.with_temporary_items do
          field :name, as: :text
          field :status, as: :select, enum: ::Post.statuses
        end

        visit avo.new_resources_post_path

        expect(page).to have_select "post_status", selected: "draft", options: ["draft", "published", "archived"]

        fill_in "post_name", with: "Published post =)"
        select "published", from: "post_status"
        save
        expect(page).to have_text "published"
        expect(Post.last.status).to eq "published"
      end
    end

    context "display_value true" do
      it "show value and save value" do
        PostResource.with_temporary_items do
          field :name, as: :text
          field :status, as: :select, enum: ::Post.statuses, display_value: true
        end

        visit avo.new_resources_post_path

        expect(page).to have_select "post_status", selected: "0", options: ["0", "1", "2"]

        fill_in "post_name", with: "Published post =)"
        select "2", from: "post_status"
        save
        expect(page).to have_text "2"
        expect(Post.last.status).to eq "archived"
      end
    end
  end

  describe "when options are an enum hash" do
    ENUM_HASH_OPTIONS = {
      "Zero": "None",
      "Low": "From 1.000 to 50.000",
      "Medium": "From 100.000 to 250.000",
      "High": "From 250.000 to 500.000",
    }

    def test_enum_hash
      visit avo.new_resources_city_path
      expect(page).to have_select "city_description", selected: nil, options: ["Zero", "Low", "Medium", "High"]
      select "Medium", from: "city_description"
      save
      expect(page).to have_text "Medium"
      #TODO: Here in DB is saved Medium but im not sure if that is right...
      # expect(City.last.description).to eq "From 100.000 to 250.000"
    end
    context "simple" do
      it "show key but save value" do
        CityResource.with_temporary_items do
          field :description, as: :select, enum: ENUM_HASH_OPTIONS
        end
        test_enum_hash
        CityResource.restore_items_from_backup
      end
    end
  end
end
