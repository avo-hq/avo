require "rails_helper"

RSpec.describe "badge", type: :feature do
  shared_examples "badge rendering" do
    describe "without value" do
      let!(:project) { create :project, users_required: 15, stage: nil }

      it {
        is_expected.to have_text empty_dash
        is_expected.not_to have_css ".badge"
      }
    end

    describe "with info value" do
      let(:stage) { "Discovery" }
      let!(:project) { create :project, users_required: 15, stage: stage }

      it {
        is_expected.to have_text stage
        is_expected.to have_css ".badge.badge--subtle.badge--info"
      }
    end

    describe "with success value" do
      let(:stage) { "Done" }
      let!(:project) { create :project, users_required: 15, stage: stage }

      it {
        is_expected.to have_text stage
        is_expected.to have_css ".badge.badge--solid.badge--success"
      }
    end

    describe "with warning value" do
      let(:stage) { "On hold" }
      let!(:project) { create :project, users_required: 15, stage: stage }

      it {
        is_expected.to have_text stage
        is_expected.to have_css ".badge.badge--subtle.badge--warning"
      }
    end

    describe "with danger value" do
      let(:stage) { "Cancelled" }
      let!(:project) { create :project, users_required: 15, stage: stage }

      it {
        is_expected.to have_text stage
        is_expected.to have_css ".badge.badge--solid.badge--danger"
      }
    end

    describe "with violet value" do
      let(:stage) { "Idea" }
      let!(:project) { create :project, users_required: 15, stage: stage }

      it {
        is_expected.to have_text stage
        is_expected.to have_css ".badge.badge--subtle.badge--violet"
      }
    end

    describe "with neutral value" do
      let(:stage) { "Drafting" }
      let!(:project) { create :project, users_required: 15, stage: stage }

      it {
        is_expected.to have_text stage
        is_expected.to have_css ".badge.badge--subtle.badge--neutral"
      }
    end
  end

  context "index" do
    subject do
      visit "/admin/resources/projects"
      find("[data-resource-id='#{project.id}'] [data-field-id='stage']")
    end

    describe "has minimum width" do
      let!(:project) { create :project, users_required: 15, stage: "Discovery" }

      it { is_expected.to have_css ".min-w-24" }
    end

    include_examples "badge rendering"
  end

  context "show" do
    subject do
      visit "/admin/resources/projects/#{project.id}"
      find_field_value_element("stage")
    end

    include_examples "badge rendering"
  end
end
