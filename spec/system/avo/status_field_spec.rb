require "rails_helper"

RSpec.describe "StatusField", type: :system do
  describe "without value" do
    let!(:project) { create :project, status: "" }

    context "index" do
      it "displays the empty state status" do
        visit "/avo/resources/projects"

        expect(find_field_element("status")).to have_text empty_dash
      end
    end

    context "show" do
      it "displays the projects status" do
        visit "/avo/resources/projects/#{project.id}"

        expect(find_field_value_element("status")).to have_text empty_dash
      end
    end

    context "edit" do
      it "has the projects status pre-filled" do
        visit "/avo/resources/projects/#{project.id}/edit"

        expect(find_field("project_status").value).to eq ""
      end
    end
  end

  describe "with waiting value" do
    let!(:project) { create :project, status: "waiting" }

    context "index" do
      it "displays the empty state status" do
        visit "/avo/resources/projects"

        expect(find_field_element("status")).to have_text "waiting"
        expect(find_field_element("status")).to have_css ".spinner"
      end

      it "displays the projects status" do
        visit "/avo/resources/projects"

        expect(find_field_element("status")).to have_text "waiting"
        expect(find_field_element("status")).to have_css ".spinner"
      end
    end

    context "show" do
      it "displays the projects status" do
        visit "/avo/resources/projects/#{project.id}"

        expect(find_field_element("status")).to have_text "waiting"
        expect(find_field_element("status")).to have_css ".spinner"
      end
    end

    context "edit" do
      it "has the projects status pre-filled" do
        visit "/avo/resources/projects/#{project.id}/edit"

        expect(find_field("project_status").value).to eq "waiting"
      end

      it "changes the projects status to normal" do
        visit "/avo/resources/projects/#{project.id}/edit"

        fill_in "project_status", with: "normal"

        click_on "Save"
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"

        expect(find_field_element("status")).to have_text "normal"
        expect(find_field_element("status")).not_to have_css ".text-red-600"
        expect(find_field_element("status")).not_to have_css ".spinner"
      end

      it "changes the projects status to failed" do
        visit "/avo/resources/projects/#{project.id}/edit"

        fill_in "project_status", with: "failed"

        click_on "Save"
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"
        expect(find_field_value_element("status")).to have_text "failed"
        expect(find_field_element("status")).to have_css ".text-red-600"
        expect(find_field_element("status")).not_to have_css ".spinner"
      end

      it "changes the projects status to waiting" do
        visit "/avo/resources/projects/#{project.id}/edit"

        fill_in "project_status", with: "waiting"

        click_on "Save"
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"

        expect(find_field_element("status")).to have_text "waiting"
        expect(find_field_element("status")).to have_css ".spinner"
        expect(find_field_element("status")).not_to have_css ".text-red-600"
      end
    end
  end
end
