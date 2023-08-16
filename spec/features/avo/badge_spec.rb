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
        is_expected.not_to have_css ".rounded-md"
      }
    end

    describe "with info value" do
      let(:stage) { "Discovery" }
      let!(:project) { create :project, users_required: 15, stage: stage }

      it {
        is_expected.to have_text stage
        is_expected.to have_css ".rounded-md"
        is_expected.to have_css ".bg-blue-500"
      }
    end

    describe "with success value" do
      let(:stage) { "Done" }
      let!(:project) { create :project, users_required: 15, stage: stage }

      it {
        is_expected.to have_text stage
        is_expected.to have_css ".rounded-md"
        is_expected.to have_css ".bg-green-500"
      }
    end

    describe "with warning value" do
      let(:stage) { "On hold" }
      let!(:project) { create :project, users_required: 15, stage: stage }

      it {
        is_expected.to have_text stage
        is_expected.to have_css ".rounded-md"
        is_expected.to have_css ".bg-yellow-500"
      }
    end

    describe "with danger value" do
      let(:stage) { "Cancelled" }
      let!(:project) { create :project, users_required: 15, stage: stage }

      it {
        is_expected.to have_text stage
        is_expected.to have_css ".rounded-md"
        is_expected.to have_css ".bg-red-500"
      }
    end

    describe "with secondary value" do
      let(:stage) { "Drafting" }
      let!(:project) { create :project, users_required: 15, stage: stage }

      it {
        is_expected.to have_text stage
        is_expected.to have_css ".rounded-md"
        is_expected.to have_css ".bg-gray-500"
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
        is_expected.not_to have_css ".rounded-md"
      }
    end

    describe "with info value" do
      let(:stage) { "Discovery" }
      let!(:project) { create :project, users_required: 15, stage: stage }

      it {
        is_expected.to have_text stage
        is_expected.to have_css ".rounded-md"
        is_expected.to have_css ".bg-blue-500"
      }
    end

    describe "with success value" do
      let(:stage) { "Done" }
      let!(:project) { create :project, users_required: 15, stage: stage }

      it {
        is_expected.to have_text stage
        is_expected.to have_css ".rounded-md"
        is_expected.to have_css ".bg-green-500"
      }
    end

    describe "with warning value" do
      let(:stage) { "On hold" }
      let!(:project) { create :project, users_required: 15, stage: stage }

      it {
        is_expected.to have_text stage
        is_expected.to have_css ".rounded-md"
        is_expected.to have_css ".bg-yellow-500"
      }
    end

    describe "with danger value" do
      let(:stage) { "Cancelled" }
      let!(:project) { create :project, users_required: 15, stage: stage }

      it {
        is_expected.to have_text stage
        is_expected.to have_css ".rounded-md"
        is_expected.to have_css ".bg-red-500"
      }
    end

    describe "with secondary value" do
      let(:stage) { "Drafting" }
      let!(:project) { create :project, users_required: 15, stage: stage }

      it {
        is_expected.to have_text stage
        is_expected.to have_css ".rounded-md"
        is_expected.to have_css ".bg-gray-500"
      }
    end
  end
end
