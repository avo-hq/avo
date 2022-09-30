require "rails_helper"

RSpec.describe "BadgeField", type: :feature do
  describe "without a value" do
    let!(:project) { create :project, stage: nil }

    subject {
      visit url
      find_field_element(:stage)
    }

    context "index" do
      let!(:url) { "/admin/resources/projects" }

      it { is_expected.to have_text empty_dash }
      it { is_expected.not_to have_css ".rounded-md" }
    end

    context "show" do
      let!(:url) { "/admin/resources/projects/#{project.id}" }

      it { is_expected.to have_text empty_dash }
      it { is_expected.not_to have_css ".rounded-md" }
    end

    context "edit" do
      let!(:url) { "/admin/resources/projects/#{project.id}/edit" }

      it "is hidden" do
        visit url

        expect(page).to have_no_selector "[field-id='stage'][field-component='badge']"
      end
    end
  end

  describe "with an info status" do
    let!(:project) { create :project, stage: "discovery" }

    subject {
      visit url
      find_field_element(:stage)
    }

    context "index" do
      let!(:url) { "/admin/resources/projects" }

      it { is_expected.to have_text "Discovery" }
      it { is_expected.to have_css ".rounded-md" }
      it { is_expected.to have_css ".bg-blue-500" }
      it { is_expected.not_to have_css ".bg-red-500" }
    end

    context "show" do
      let!(:url) { "/admin/resources/projects/#{project.id}" }

      it { is_expected.to have_text "Discovery" }
      it { is_expected.to have_css ".rounded-md" }
      it { is_expected.to have_css ".bg-blue-500" }
      it { is_expected.not_to have_css ".bg-red-500" }
    end
  end

  describe "with a danger status" do
    let!(:project) { create :project, stage: "cancelled" }

    subject {
      visit url
      find_field_element(:stage)
    }

    context "index" do
      let!(:url) { "/admin/resources/projects" }

      it { is_expected.to have_text "Cancelled" }
      it { is_expected.to have_css ".rounded-md" }
      it { is_expected.to have_css ".bg-red-500" }
      it { is_expected.not_to have_css ".bg-blue-500" }
    end

    context "show" do
      let!(:url) { "/admin/resources/projects/#{project.id}" }

      it { is_expected.to have_text "Cancelled" }
      it { is_expected.to have_css ".rounded-md" }
      it { is_expected.to have_css ".bg-red-500" }
      it { is_expected.not_to have_css ".bg-blue-500" }
    end
  end
end
