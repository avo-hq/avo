require "rails_helper"

RSpec.describe "CountryField", type: :system do
  describe "without a value" do
    let!(:project) { create :project, country: nil }

    subject do
      visit url
      find_field_element(:country)
    end

    context "index" do
      let!(:url) { "/avo/resources/projects" }

      it { is_expected.to have_text empty_dash }
    end

    context "show" do
      let!(:url) { "/avo/resources/projects/#{project.id}" }

      it { is_expected.to have_text empty_dash }
    end

    context "edit" do
      let!(:url) { "/avo/resources/projects/#{project.id}/edit" }

      it "displays the placeholder" do
        visit url

        expect(page).to have_select "Country", selected: "Choose a country"
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
      let!(:url) { "/avo/resources/projects" }

      it { is_expected.to have_text country_name }
    end

    context "show" do
      let!(:url) { "/avo/resources/projects/#{project.id}" }

      it { is_expected.to have_text country_name }
    end

    context "edit" do
      let!(:url) { "/avo/resources/projects/#{project.id}/edit" }

      it { is_expected.to have_select "project_country", selected: country_name }

      it "changes the country" do
        visit url

        select "United States Minor Outlying Islands", from: "project[country]"

        click_on "Save"
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"
        expect(find_field_element(:country)).to have_text "United States Minor Outlying Islands"
        expect(project.reload.country).to eql "UM"
      end
    end
  end
end
