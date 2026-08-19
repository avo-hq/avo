require "rails_helper"

RSpec.describe "number", type: :feature do
  context "index" do
    let(:url) { "/admin/resources/projects" }

    subject do
      visit url
      find("[data-resource-id='#{project.to_param}'] [data-field-id='users_required']")
    end

    describe "with value" do
      let(:users_required) { 2026 }
      let!(:project) { create :project, users_required: users_required }

      it "renders a bare number without formatting or end alignment" do
        expect(subject).to have_text "2026"
        expect(subject[:class].split).to include("tabular-nums")
        expect(subject[:class].split).not_to include("text-end")

        header = find("th[data-table-header-field-id='users_required']")
        expect(header[:class].split).to include("text-start")
        expect(header[:class].split).not_to include("text-end")
        expect(header.all("div").first[:class].split).not_to include("flex-row-reverse")
      end

      it "uses tabular figures for id columns" do
        visit url

        id_cell = find("[data-resource-id='#{project.to_param}'] [data-field-id='id']")

        expect(id_cell[:class].split).to include("tabular-nums")
      end
    end
  end

  subject do
    visit url
    find_field_element("users_required")
  end

  context "show" do
    let(:url) { "/admin/resources/projects/#{project.id}" }

    describe "with value" do
      let(:users_required) { 50 }
      let!(:project) { create :project, users_required: users_required }

      it { is_expected.to have_text users_required }
    end
  end

  context "edit" do
    let(:url) { "/admin/resources/projects/#{project.id}/edit" }

    describe "with value" do
      let(:users_required) { 50 }
      let(:new_users_required) { 100 }
      let(:under_min_users_required) { 9 }
      let(:over_max_users_required) { 1000001 }
      let!(:project) { create :project, users_required: users_required }

      it { is_expected.to have_xpath "//input[@id='project_users_required'][@type='number'][@placeholder='Users required'][@min='10.0'][@max='1000000.0'][@step='1.0'][@value='#{users_required}']" }

      it "changes the users_required to correct value" do
        is_expected.to have_xpath "//input[@id='project_users_required'][@type='number'][@placeholder='Users required'][@min='10.0'][@max='1000000.0'][@step='1.0'][@value='#{users_required}']"

        fill_in "project_users_required", with: new_users_required

        save

        expect(current_path).to eql "/admin/resources/projects/#{project.id}"
        is_expected.to have_text new_users_required
      end

      it "changes the users_required to value under minimum" do
        is_expected.to have_xpath "//input[@id='project_users_required'][@type='number'][@placeholder='Users required'][@min='10.0'][@max='1000000.0'][@step='1.0'][@value='#{users_required}']"

        fill_in "project_users_required", with: under_min_users_required

        save

        expect(current_path).to eql "/admin/resources/projects/#{project.id}"
        is_expected.to have_text "Users required must be greater than 9"
      end

      it "changes the users_required to value over maximum" do
        is_expected.to have_xpath "//input[@id='project_users_required'][@type='number'][@placeholder='Users required'][@min='10.0'][@max='1000000.0'][@step='1.0'][@value='#{users_required}']"

        fill_in "project_users_required", with: over_max_users_required

        save

        expect(current_path).to eql "/admin/resources/projects/#{project.id}"
        is_expected.to have_text "Users required must be less than 1000000"
      end

      it "clears the users_required" do
        is_expected.to have_xpath "//input[@id='project_users_required'][@type='number'][@placeholder='Users required'][@min='10.0'][@max='1000000.0'][@step='1.0'][@value='#{users_required}']"

        fill_in "project_users_required", with: "nil"

        save

        expect(current_path).to eql "/admin/resources/projects/#{project.id}"
        is_expected.to have_text "Users required is not a number"
      end
    end
  end

  describe "format" do
    let!(:city) { create :city, population: 8_419_600 }

    it "delimits display values and keeps the edit input raw" do
      visit "/admin/resources/cities"

      cell = find("[data-resource-id='#{city.to_param}'] [data-field-id='population']")
      expect(cell).to have_text("8,419,600")
      expect(cell[:class].split).to include("tabular-nums", "text-end")

      header = find("th[data-table-header-field-id='population']")
      expect(header[:class].split).to include("text-end")
      expect(header[:class].split).not_to include("text-start")
      expect(header.all("div").first[:class].split).to include("flex-row-reverse")

      visit "/admin/resources/cities/#{city.id}"
      expect(find_field_element(:population)).to have_text("8,419,600")

      visit "/admin/resources/cities/#{city.id}/edit"
      expect(page).to have_field("city_population", with: "8419600")

      fill_in "city_population", with: "8419601"
      save

      expect(city.reload.population).to eq 8_419_601
    end

    it "reverses the sortable header layout" do
      project = create :project, users_required: 10_000

      Avo::Resources::Project.with_temporary_items do
        field :users_required, as: :number, format: :delimited, sortable: true
      end

      visit "/admin/resources/projects"

      header = find("th[data-table-header-field-id='users_required']")
      expect(header[:class].split).to include("text-end")
      expect(header.all("div").first[:class].split).to include("flex-row-reverse")
      expect(header.find("a")[:class].split).to include("flex-row-reverse")
      expect(find("[data-resource-id='#{project.to_param}'] [data-field-id='users_required']")).to have_text("10,000")
    ensure
      Avo::Resources::Project.restore_items_from_backup
    end
  end

  describe "formats a value based on the specified formatter for that field" do
    let!(:project) { create :project, users_required: 10000 }

    context "with format_show_using" do
      it "formats the value of a field on the show page when the format_show_using formatter is present" do
        Avo::Resources::Project.with_temporary_items do
          field :users_required, as: :number, format_show_using: -> { number_with_delimiter value }
        end

        visit "/admin/resources/projects/#{project.id}"

        expect(find_field_element(:users_required)).to have_text("10,000")
      ensure
        Avo::Resources::Project.restore_items_from_backup
      end
    end

    context "with format_index_using" do
      it "formats the value of a field on the index page when the format_index_using formatter is present" do
        Avo::Resources::Project.with_temporary_items do
          field :users_required, as: :number, format_index_using: -> { number_with_delimiter value }
        end

        visit "/admin/resources/projects"

        expect(find_field_element(:users_required)).to have_text("10,000")
      ensure
        Avo::Resources::Project.restore_items_from_backup
      end
    end

    context "with format_display_using" do
      it "overrides format on both the index and show pages" do
        Avo::Resources::Project.with_temporary_items do
          field :users_required,
            as: :number,
            format: :human,
            format_display_using: -> { number_with_delimiter value }
        end

        visit "/admin/resources/projects"

        expect(find_field_element(:users_required)).to have_text("10,000")

        visit "/admin/resources/projects/#{project.id}"

        expect(find_field_element(:users_required)).to have_text("10,000")
      ensure
        Avo::Resources::Project.restore_items_from_backup
      end
    end

    context "with format_edit_using" do
      it "formats the value of a field on the edit page when the format_edit_using formatter is present" do
        Avo::Resources::Project.with_temporary_items do
          field :users_required, as: :number, format_edit_using: -> { number_with_delimiter value }
        end

        visit "/admin/resources/projects/#{project.id}/edit"

        expect(page).to have_field("project_users_required", with: "10,000")
      ensure
        Avo::Resources::Project.restore_items_from_backup
      end
    end

    context "with format_form_using" do
      it "formats the value of a field on a form page when the format_form_using formatter is present" do
        Avo::Resources::Project.with_temporary_items do
          field :users_required, as: :number, format_edit_using: -> { number_with_delimiter value }
        end

        visit "/admin/resources/projects/#{project.id}/edit"

        expect(page).to have_field("project_users_required", with: "10,000")
      ensure
        Avo::Resources::Project.restore_items_from_backup
      end
    end
  end
end
