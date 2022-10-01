require "rails_helper"

RSpec.describe "NullableField", type: :feature do
  describe 'without input (specifying null_values: ["", "0", "null", "nil"])' do
    let!(:team) { create :team, description: nil, url: "http://google.com" }

    context "show" do
      it "displays the teams empty description (dash)" do
        visit "/admin/resources/teams/#{team.id}"

        expect(find_field_value_element("description")).to have_text empty_dash
      end
    end

    context "edit" do
      it "has the teams description empty" do
        visit "/admin/resources/teams/#{team.id}/edit"

        expect(find_field("team_description").value).to eq ""
      end
    end
  end

  describe 'with regular input (specifying null_values: ["", "0", "null", "nil"])' do
    let!(:team) { create :team, description: "descr" }

    context "edit" do
      it "has the teams description pre-filled" do
        visit "/admin/resources/teams/#{team.id}/edit"

        expect(find_field("team_description").value).to eq "descr"
      end

      it 'changes the teams description to null ("" - empty string)' do
        visit "/admin/resources/teams/#{team.id}/edit"

        fill_in "team_description", with: ""
        click_on "Save"
        wait_for_loaded

        expect(current_path).to eql "/admin/resources/teams/#{team.id}"
        expect(find_field_value_element("description")).to have_text empty_dash
      end

      it 'changes the teams description to null ("0")' do
        visit "/admin/resources/teams/#{team.id}/edit"

        fill_in "team_description", with: "0"
        click_on "Save"
        wait_for_loaded

        expect(current_path).to eql "/admin/resources/teams/#{team.id}"
        expect(find_field_value_element("description")).to have_text empty_dash
      end

      it 'changes the teams description to null ("nil")' do
        visit "/admin/resources/teams/#{team.id}/edit"

        fill_in "team_description", with: "nil"
        click_on "Save"
        wait_for_loaded

        expect(current_path).to eql "/admin/resources/teams/#{team.id}"
        expect(find_field_value_element("description")).to have_text empty_dash
      end

      it 'changes the teams description to null ("null")' do
        visit "/admin/resources/teams/#{team.id}/edit"

        fill_in "team_description", with: "null"
        click_on "Save"
        wait_for_loaded

        expect(current_path).to eql "/admin/resources/teams/#{team.id}"
        expect(find_field_value_element("description")).to have_text empty_dash
      end
    end
  end

  describe "without input (without specifying null_values)" do
    let!(:project) { create :project, status: nil }

    context "show" do
      it "displays the projects empty status (dash)" do
        visit "/admin/resources/projects/#{project.id}"

        expect(find_field_value_element("status")).to have_text empty_dash
      end
    end

    context "edit" do
      it "has the projects status empty" do
        visit "/admin/resources/projects/#{project.id}/edit"

        expect(find_field("project_status").value.to_s).to eq ""
      end
    end
  end

  describe "with regular input (without specifying null_values)" do
    let!(:project) { create :project, status: "rejected" }

    context "edit" do
      it "has the projects status pre-filled" do
        visit "/admin/resources/projects/#{project.id}/edit"

        expect(find_field("project_status").value).to eq "rejected"
      end

      it 'changes the projects status to null ("" - empty string)' do
        visit "/admin/resources/projects/#{project.id}/edit"

        fill_in "project_status", with: ""
        click_on "Save"
        wait_for_loaded
        sleep 0.1

        expect(current_path).to eql "/admin/resources/projects/#{project.id}"
        expect(find_field_value_element("status")).to have_text empty_dash
      end
    end
  end
end
