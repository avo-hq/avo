require "rails_helper"

RSpec.describe "SelectField", type: :feature do
  describe "enum hash display_value: true" do
    context "index" do
      let(:url) { "/avo/resources/projects" }

      subject do
        visit url
        find("[data-resource-id='#{project.id}'] [data-field-id='stage']")
      end

      describe "without stage" do
        let!(:project) { create :project, users_required: 15, stage: nil }

        it { is_expected.to have_text empty_dash }
      end

      describe "with discovery stage" do
        let(:stage) { "discovery" }
        let!(:project) { create :project, users_required: 15, stage: stage }

        it { is_expected.to have_text stage.humanize }
      end

      describe "with idea stage" do
        let(:stage) { "idea" }
        let!(:project) { create :project, users_required: 15, stage: stage }

        it { is_expected.to have_text stage.humanize }
      end

      describe "with done stage" do
        let(:stage) { "done" }
        let!(:project) { create :project, users_required: 15, stage: stage }

        it { is_expected.to have_text stage.humanize }
      end

      describe "with on hold stage" do
        let(:stage) { "on hold" }
        let!(:project) { create :project, users_required: 15, stage: stage }

        it { is_expected.to have_text stage.humanize }
      end
    end

    subject do
      visit url
      find_field_value_element("stage")
    end

    context "show" do
      let(:url) { "/avo/resources/projects/#{project.id}" }

      describe "without stage" do
        let!(:project) { create :project, users_required: 15, stage: nil }

        it { is_expected.to have_text empty_dash }
      end

      describe "with discovery stage" do
        let(:stage) { "discovery" }
        let!(:project) { create :project, users_required: 15, stage: stage }

        it { is_expected.to have_text stage.humanize }
      end

      describe "with idea stage" do
        let(:stage) { "idea" }
        let!(:project) { create :project, users_required: 15, stage: stage }

        it { is_expected.to have_text stage.humanize }
      end

      describe "with done stage" do
        let(:stage) { "done" }
        let!(:project) { create :project, users_required: 15, stage: stage }

        it { is_expected.to have_text stage.humanize }
      end

      describe "with on hold stage" do
        let(:stage) { "on hold" }
        let!(:project) { create :project, users_required: 15, stage: stage }

        it { is_expected.to have_text stage.humanize }
      end
    end

    let(:stages_without_placeholder) { ["discovery", "idea", "done", "on hold", "cancelled"] }
    let(:placeholder) { "Choose the stage" }
    let(:stages_with_placeholder) { stages_without_placeholder.prepend(placeholder) }

    context "edit" do
      let(:url) { "/avo/resources/projects/#{project.id}/edit" }

      describe "without stage" do
        let!(:project) { create :project, users_required: 15, stage: nil }
        let(:new_stage) { "idea" }

        it { is_expected.to have_select "project_stage", selected: nil, options: stages_with_placeholder }

        it "sets the stage to idea" do
          visit url

          expect(page).to have_select "project_stage", selected: nil, options: stages_with_placeholder

          select new_stage, from: "project_stage"

          click_on "Save"

          expect(current_path).to eql "/avo/resources/projects/#{project.id}"
          expect(page).to have_text new_stage.humanize
        end
      end

      describe "with stage" do
        let(:stage) { "discovery" }
        let(:new_stage) { "on hold" }
        let!(:project) { create :project, users_required: 15, stage: stage }

        it { is_expected.to have_select "project_stage", selected: stage, options: stages_without_placeholder }

        it "changes the stage to on hold" do
          visit url
          expect(page).to have_select "project_stage", selected: stage, options: stages_without_placeholder

          select new_stage, from: "project_stage"

          click_on "Save"

          expect(current_path).to eql "/avo/resources/projects/#{project.id}"
          expect(page).to have_text new_stage.humanize
        end
      end
    end

    context "create" do
      let(:url) { "/avo/resources/projects/new" }
      let(:new_stage) { "discovery" }

      describe "creates new project with stage discovery" do
        it "checks placeholder" do
          is_expected.to have_select "project_stage", selected: nil, options: stages_with_placeholder
        end

        it "saves the resource with stage discovery" do
          visit url
          expect(page).to have_select "project_stage", selected: nil, options: stages_with_placeholder

          fill_in "project_name", with: "Project X"
          fill_in "project_users_required", with: 15
          select new_stage, from: "project_stage"

          click_on "Save"

          expect(current_path).to eql "/avo/resources/projects/#{Project.last.id}"
          expect(page).to have_text "Project X"

          # Has different casing because it's the badge field.
          expect(find_field_value_element("stage")).to have_text "Discovery"
        end
      end
    end
  end
end
