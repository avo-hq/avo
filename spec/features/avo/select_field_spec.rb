require 'rails_helper'

RSpec.feature "Select", type: :feature do
  let(:project) { create :project }
  let(:placeholder) { "Choose an option" }

  before do
    Avo::Resources::Person.with_temporary_items do
      field :name, as: :text, link_to_record: true, sortable: true, stacked: true
      field :type, as: :select, name: "Type", options: {Spouse: "Spouse", Sibling: "Sibling"}, include_blank: true
    end
  end

  after :each do
    Avo::Resources::Person.restore_items_from_backup
    Avo::Resources::City.restore_items_from_backup
    Avo::Resources::Post.restore_items_from_backup
  end

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
      expect(find_field_element(:population)).to have_text("Medium")
      expect(City.last.population).to eq 100000
    end

    def test_hash_display_value
      visit avo.new_resources_city_path
      expect(page).to have_select "city_population", selected: nil, options: ["0", "50000", "100000", "250000"]
      select "250000", from: "city_population"
      save
      expect(find_field_element(:population)).to have_text("250000")
      expect(City.last.population).to eq 250000
    end

    context "simple" do
      it "show key but save value" do
        Avo::Resources::City.with_temporary_items do
          field :population, as: :select, options: HASH_OPTIONS
        end
        test_hash
      end

      it "show value and save value (display_value true)" do
        Avo::Resources::City.with_temporary_items do
          field :population, as: :select, options: HASH_OPTIONS, display_value: true
        end
        test_hash_display_value
      end
    end

    context "inside block" do
      it "show key but save value" do
        Avo::Resources::City.with_temporary_items do
          field :population, as: :select, options: -> do
            HASH_OPTIONS
          end
        end
        test_hash
      end

      it "show value and save value (display_value true)" do
        Avo::Resources::City.with_temporary_items do
          field :population, as: :select, display_value: true, options: -> do
            HASH_OPTIONS
          end
        end
        test_hash_display_value
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
        Avo::Resources::City.with_temporary_items do
          field :name, as: :select, options: ARRAY_OPTIONS
        end
        test_array
      end

      it "normal behaviour with display_value" do
        Avo::Resources::City.with_temporary_items do
          field :name, as: :select, options: ARRAY_OPTIONS, display_value: true
        end
        test_array
      end
    end

    context "inside block" do
      it "show and save the value" do
        Avo::Resources::City.with_temporary_items do
          field :name, as: :select, options: -> do
            ARRAY_OPTIONS
          end
        end
        test_array
      end

      it "normal behaviour with display_value" do
        Avo::Resources::City.with_temporary_items do
          field :name, as: :select, display_value: true, options: -> do
            ARRAY_OPTIONS
          end
        end
        test_array
      end
    end

  end

  describe "when options are enum array" do
    context "simple" do
      it "show key but save value" do
        Avo::Resources::Post.with_temporary_items do
          field :name, as: :text
          field :status, as: :select, enum: ::Post.statuses
        end

        visit avo.new_resources_post_path

        expect(page).to have_select "post_status", selected: "draft", options: ["draft", "published", "archived"]

        fill_in "post_name", with: "Published post =)"
        select "published", from: "post_status"
        save
        expect(find_field_element(:status)).to have_text("published")
        expect(Post.last.status).to eq "published"
      end
    end

    context "display_value true" do
      it "show value and save value" do
        Avo::Resources::Post.with_temporary_items do
          field :name, as: :text
          field :status, as: :select, enum: ::Post.statuses, display_value: true
        end

        visit avo.new_resources_post_path

        expect(page).to have_select "post_status", selected: "0", options: ["0", "1", "2"]

        fill_in "post_name", with: "Published post =)"
        select "2", from: "post_status"
        save
        expect(find_field_element(:status)).to have_text("2")
        expect(Post.last.status).to eq "archived"
      end
    end
  end

  describe "when options are an enum hash" do
    context "simple" do
      it "without display value" do
        Avo::Resources::City.with_temporary_items do
          field :status, as: :select, enum: City.statuses
        end
        visit avo.new_resources_city_path
        expect(page).to have_select "city_status", selected: nil, options: ["Open", "Closed", "Quarantine"]
        select "Quarantine", from: "city_status"
        save
        expect(find_field_element(:status)).to have_text("Quarantine")
        expect(City.last.status).to eq "Quarantine"
      end

      it "display_value true" do
        Avo::Resources::City.with_temporary_items do
          field :status, as: :select, enum: City.statuses, display_value: true
        end
        visit avo.new_resources_city_path
        expect(page).to have_select "city_status", selected: nil, options: ["open", "closed", "On Quarantine"]
        select "On Quarantine", from: "city_status"
        save
        expect(find_field_element(:status)).to have_text("On Quarantine")
        expect(City.last.status).to eq "Quarantine"
      end
    end
  end
end
