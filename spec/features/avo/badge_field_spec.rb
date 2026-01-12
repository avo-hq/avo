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
        expect(subject).to have_css ".badge.badge--subtle.badge--info.min-w-24"
        expect(subject).not_to have_css ".badge--danger"
      end
    end

    context "show" do
      let!(:url) { "/admin/resources/projects/#{project.id}" }

      it "renders a badge with correct classes" do
        expect(subject).to have_text "Discovery"
        expect(subject).to have_css ".badge.badge--subtle.badge--info"
        expect(subject).not_to have_css ".badge--danger.min-w-24"
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
        expect(subject).to have_css ".badge.badge--solid.badge--danger.min-w-24"
      end
    end

    context "show" do
      let!(:url) { "/admin/resources/projects/#{project.id}" }

      it "renders a badge with correct classes" do
        expect(subject).to have_text "Cancelled"
        expect(subject).to have_css ".badge.badge--solid.badge--danger"
        expect(subject).not_to have_css ".badge--success.min-w-24"
      end
    end
  end

  describe "with a violet status" do
    let!(:project) { create :project, stage: "idea" }

    subject {
      visit url
      find_field_element(:stage)
    }

    context "index" do
      let!(:url) { "/admin/resources/projects" }

      it "renders a badge with correct classes" do
        expect(subject).to have_text "Idea"
        expect(subject).to have_css ".badge.badge--subtle.badge--violet.min-w-24"
        expect(subject).not_to have_css ".badge--info"
      end
    end

    context "show" do
      let!(:url) { "/admin/resources/projects/#{project.id}" }

      it "renders a badge with correct classes" do
        expect(subject).to have_text "Idea"
        expect(subject).to have_css ".badge.badge--subtle.badge--violet"
        expect(subject).not_to have_css ".badge--info.min-w-24"
      end
    end
  end

  describe "with a neutral status" do
    let!(:project) { create :project, stage: "drafting" }

    subject {
      visit url
      find_field_element(:stage)
    }

    context "index" do
      let!(:url) { "/admin/resources/projects" }

      it "renders a badge with correct classes" do
        expect(subject).to have_text "Drafting"
        expect(subject).to have_css ".badge.badge--subtle.badge--neutral.min-w-24"
        expect(subject).not_to have_css ".badge--blue"
      end
    end

    context "show" do
      let!(:url) { "/admin/resources/projects/#{project.id}" }

      it "renders a badge with correct classes" do
        expect(subject).to have_text "Drafting"
        expect(subject).to have_css ".badge.badge--subtle.badge--neutral"
        expect(subject).not_to have_css ".badge--blue.min-w-24"
      end
    end
  end
end
