require "rails_helper"

RSpec.describe "badge", type: :feature do
  context "index" do
    let(:url) { "/admin/resources/projects" }

    subject do
      visit url
      find("[data-resource-id='#{project.id}'] [data-field-id='stage']")
    end

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
        is_expected.to have_css ".badge.badge--subtle.badge--green"
      }
    end

    describe "with success value" do
      let(:stage) { "Done" }
      let!(:project) { create :project, users_required: 15, stage: stage }

      it {
        is_expected.to have_text stage
        is_expected.to have_css ".badge.badge--solid.badge--green"
      }
    end

    describe "with warning value" do
      let(:stage) { "On hold" }
      let!(:project) { create :project, users_required: 15, stage: stage }

      it {
        is_expected.to have_text stage
        is_expected.to have_css ".badge.badge--subtle.badge--orange"
      }
    end

    describe "with danger value" do
      let(:stage) { "Cancelled" }
      let!(:project) { create :project, users_required: 15, stage: stage }

      it {
        is_expected.to have_text stage
        is_expected.to have_css ".badge.badge--solid.badge--orange"
      }
    end

    describe "with neutral value" do
      let(:stage) { "Drafting" }
      let!(:project) { create :project, users_required: 15, stage: stage }

      it {
        is_expected.to have_text stage
        is_expected.to have_css ".badge.badge--subtle.badge--purple"
      }
    end
  end

  context "show" do
    let(:url) { "/admin/resources/projects/#{project.id}" }

    subject do
      visit url
      find_field_value_element("stage")
    end

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
        is_expected.to have_css ".badge.badge--subtle.badge--green"
      }
    end

    describe "with success value" do
      let(:stage) { "Done" }
      let!(:project) { create :project, users_required: 15, stage: stage }

      it {
        is_expected.to have_text stage
        is_expected.to have_css ".badge.badge--solid.badge--green"
      }
    end

    describe "with warning value" do
      let(:stage) { "On hold" }
      let!(:project) { create :project, users_required: 15, stage: stage }

      it {
        is_expected.to have_text stage
        is_expected.to have_css ".badge.badge--subtle.badge--orange"
      }
    end

    describe "with danger value" do
      let(:stage) { "Cancelled" }
      let!(:project) { create :project, users_required: 15, stage: stage }

      it {
        is_expected.to have_text stage
        is_expected.to have_css ".badge.badge--solid.badge--orange"
      }
    end

    describe "with neutral value" do
      let(:stage) { "Drafting" }
      let!(:project) { create :project, users_required: 15, stage: stage }

      it {
        is_expected.to have_text stage
        is_expected.to have_css ".badge.badge--subtle.badge--purple"
      }
    end
  end
end
