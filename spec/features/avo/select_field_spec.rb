require "rails_helper"

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

  describe "when options are multiple select" do
    context "new" do
      it "allow selection of multiple values" do
        visit avo.new_resources_product_path

        expect(page).to have_select "product_sizes", multiple: true, options: ["Large", "Medium", "Small"]

        select "Large", from: "product_sizes"
        select "Medium", from: "product_sizes"

        save

        expect(find_field_element(:sizes)).to have_text("Large, Medium")
        expect(Product.last.sizes).to match_array(["large", "medium"])
      end
    end

    context "edit" do
      let(:product) { create :product, sizes: [:large] }

      it "allow changing of selected values" do
        visit avo.edit_resources_product_path(product)

        expect(page).to have_select "product_sizes", selected: ["Large"], multiple: true, options: ["Large", "Medium", "Small"]

        select "Medium", from: "product_sizes"
        select "Small", from: "product_sizes"

        save

        expect(find_field_element(:sizes)).to have_text("Large, Medium, Small")
        expect(Product.last.sizes).to match_array(["medium", "small", "large"])
      end

      it "allow deselecting of previously selected values" do
        visit avo.edit_resources_product_path(product)

        expect(page).to have_select "product_sizes", selected: ["Large"], multiple: true, options: ["Large", "Medium", "Small"]

        page.unselect "Large", from: "Sizes"

        save

        expect(find_field_element(:sizes)).to have_text("—")
        expect(Product.last.sizes).to match_array([])
      end
    end
  end

  describe "when options are grouped" do
    let!(:event) { create :event, name: "Event 1" }
    let!(:volunteer) { create :volunteer, name: "John Doe", role: "Helper" }

    context "single select with grouped options" do
      it "shows grouped options and saves the selected value" do
        visit avo.new_resources_volunteer_path

        expect(page).to have_select "volunteer_department"

        # Check grouped options structure
        within "select[name='volunteer[department]']" do
          expect(page).to have_selector "optgroup[label='Administration']"
          expect(page).to have_selector "optgroup[label='Operations']"
          expect(page).to have_selector "optgroup[label='Technology']"
        end

        select "HR", from: "volunteer_department"
        fill_in "volunteer_name", with: "Jane Smith"
        fill_in "volunteer_role", with: "Administrator"

        select "Event 1", from: "volunteer_event_id"

        save

        expect(find_field_element(:department)).to have_text("HR")
        expect(Volunteer.last.department).to eq "hr"
      end

      it "displays the correct selected value on edit" do
        volunteer.update!(department: "Finance")
        visit avo.edit_resources_volunteer_path(volunteer)

        expect(page).to have_select "volunteer_department", selected: "Finance"
      end
    end

    context "multiple select with grouped options" do
      it "allows selection of multiple grouped values" do
        visit avo.new_resources_volunteer_path

        expect(page).to have_select "volunteer_skills", multiple: true

        # Check grouped options structure
        within "select[name='volunteer[skills][]']" do
          expect(page).to have_selector "optgroup[label='Technical Skills']"
          expect(page).to have_selector "optgroup[label='Communication Skills']"
          expect(page).to have_selector "optgroup[label='Leadership Skills']"
        end

        select "Programming", from: "volunteer_skills"
        select "Public Speaking", from: "volunteer_skills"
        fill_in "volunteer_name", with: "Tech Leader"
        fill_in "volunteer_role", with: "Volunteer"

        select "Event 1", from: "volunteer_event_id"

        save

        expect(find_field_element(:skills)).to have_text("Programming, Public Speaking")
        expect(Volunteer.last.skills).to match_array(["programming", "public_speaking"])
      end

      it "displays the correct selected values on edit" do
        volunteer.update(skills: ["database", "team_mgmt"])
        visit avo.edit_resources_volunteer_path(volunteer)

        expect(page).to have_select "volunteer_skills", selected: ["Database Management", "Team Management"], multiple: true
      end

      it "allows deselecting previously selected values" do
        volunteer.update(skills: ["programming", "writing"])
        visit avo.edit_resources_volunteer_path(volunteer)

        expect(page).to have_select "volunteer_skills", selected: ["Programming", "Writing"], multiple: true

        page.unselect "Programming", from: "Skills"

        save

        expect(find_field_element(:skills)).to have_text("Writing")
        expect(Volunteer.last.skills).to match_array(["writing"])
      end
    end
  end
end
