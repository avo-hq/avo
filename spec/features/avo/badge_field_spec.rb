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
      it { expect(subject).not_to have_css ".badge" }
    end

    context "show" do
      let!(:url) { "/admin/resources/projects/#{project.id}" }

      it { is_expected.to have_text empty_dash }
      it { expect(subject).not_to have_css ".badge" }
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

      it "renders a badge with correct classes" do
        expect(subject).to have_text "Discovery"
        expect(subject).to have_css ".badge.badge--subtle.badge--green.min-w-28"
        expect(subject).not_to have_css ".badge--error"
      end
    end

    context "show" do
      let!(:url) { "/admin/resources/projects/#{project.id}" }

      it "renders a badge with correct classes" do
        expect(subject).to have_text "Discovery"
        expect(subject).to have_css ".badge.badge--subtle.badge--green.min-w-28"
        expect(subject).not_to have_css ".badge--error"
      end
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

      it "renders a badge with correct classes" do
        expect(subject).to have_text "Cancelled"
        expect(subject).to have_css ".badge.badge--solid.badge--orange.min-w-28"
      end
    end

    context "show" do
      let!(:url) { "/admin/resources/projects/#{project.id}" }

      it "renders a badge with correct classes" do
        expect(subject).to have_text "Cancelled"
        expect(subject).to have_css ".badge.badge--solid.badge--orange.min-w-28"
      end
    end
  end

  describe "with a secondary status" do
    let!(:project) { create :project, stage: "drafting" }

    subject {
      visit url
      find_field_element(:stage)
    }

    context "index" do
      let!(:url) { "/admin/resources/projects" }

      it "renders a badge with correct classes" do
        expect(subject).to have_text "Drafting"
        expect(subject).to have_css ".badge.badge--subtle.badge--purple.min-w-28"
        expect(subject).not_to have_css ".badge--blue"
      end
    end

    context "show" do
      let!(:url) { "/admin/resources/projects/#{project.id}" }

      it "renders a badge with correct classes" do
        expect(subject).to have_text "Drafting"
        expect(subject).to have_css ".badge.badge--subtle.badge--purple.min-w-28"
        expect(subject).not_to have_css ".badge--blue"
      end
    end
  end
end
