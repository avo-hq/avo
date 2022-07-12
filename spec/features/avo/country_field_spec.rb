require "rails_helper"

RSpec.describe "CountryField", type: :feature do
  let(:countries) { ISO3166::Country.translations.sort_by { |code, name| name }.map { |code, name| name } }

  describe "without a value" do
    let!(:project) { create :project, country: nil }

    subject do
      visit url
      find_field_element(:country)
    end

    context "index" do
      let!(:url) { "/admin/resources/projects" }

      it { is_expected.to have_text empty_dash }
    end

    context "show" do
      let!(:url) { "/admin/resources/projects/#{project.id}" }

      it { is_expected.to have_text empty_dash }
    end

    context "edit" do
      let!(:url) { "/admin/resources/projects/#{project.id}/edit" }

      it "displays the placeholder" do
        visit url

        expect(page).to have_select "project_country", selected: nil, options: ['No country', *countries]
      end
    end
  end

  describe "with RO as a value" do
    let(:country_code) { "RO" }
    let(:country_name) { "Romania" }
    let!(:project) { create :project, country: country_code }

    subject do
      visit url
      find_field_element(:country)
    end

    context "index" do
      let!(:url) { "/admin/resources/projects" }

      it { is_expected.to have_text country_name }
    end

    context "show" do
      let!(:url) { "/admin/resources/projects/#{project.id}" }

      it { is_expected.to have_text country_name }
    end

    context "edit" do
      let!(:url) { "/admin/resources/projects/#{project.id}/edit" }

      it { is_expected.to have_select "project_country", selected: country_name, options: ['No country', *countries] }

      it "changes the country" do
        visit url

        select "United States Minor Outlying Islands", from: "project[country]"

        click_on "Save"
        wait_for_loaded

        expect(current_path).to eql "/admin/resources/projects/#{project.id}"
        expect(find_field_element(:country)).to have_text "United States Minor Outlying Islands"
        expect(project.reload.country).to eql "UM"
      end
    end
  end
end
