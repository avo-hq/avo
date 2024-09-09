require "rails_helper"

RSpec.feature "Breadcrumbs", type: :feature do
  let!(:project) { create :project, users: [admin] }
  let!(:url) { "/admin/resources/projects/#{project.id}/edit" }

  before do
    visit url
  end

  subject { page.body }

  describe "with breadcrumbs" do
    it { is_expected.to have_css ".breadcrumbs" }
    it { is_expected.to have_text "Home\n  \n\nProjects\n  \n\n#{project.name}\n  \n\nEdit\n" }
  end

  describe "on a custom tool" do
    let!(:url) { "/admin/custom_tool" }

    it { is_expected.to have_css ".breadcrumbs" }
    it { is_expected.to have_text "Home\n" }
  end

  describe "on a has_and_belongs_to_many turbo frame" do
    let!(:user) { create(:user) }
    let!(:team) { create(:team) }

    context "when HTML request" do
      it "displays breadcrumbs" do
        url = "/admin/resources/users/#{user.slug}/teams?view=show"
        visit url

        expect(page).to have_selector ".breadcrumbs"
        expect(page.find(".breadcrumbs").text).to eq "Home Users #{user.name} Teams"

        breadcrumbs = find(".breadcrumbs")
        expect(breadcrumbs).to have_link "Home"
        expect(breadcrumbs).to have_link "Users"
        expect(breadcrumbs).to have_link user.name.to_s
        expect(breadcrumbs).to_not have_link "Teams"
      end

      it "displays breadcrumbs" do
        url = "/admin/resources/teams/#{team.id}/team_members?view=show"
        visit url

        expect(page).to have_selector ".breadcrumbs"
        expect(page.find(".breadcrumbs").text).to eq "Home Teams #{team.name} Users"

        breadcrumbs = find(".breadcrumbs")
        expect(breadcrumbs).to have_link "Home"
        expect(breadcrumbs).to have_link "Teams"
        expect(breadcrumbs).to have_link team.name.to_s
        expect(breadcrumbs).to_not have_link "Users"
      end

      it "displays a back button" do
        url = "/admin/resources/teams/#{team.id}/team_members?view=show"
        visit url

        expect(page).to have_selector "div[data-target='panel-tools'] a[href='/admin/resources/teams/#{team.id}']", text: "Go back"
      end
    end

    context "when Turbo request" do
      before(:example) do
        url = "/admin/resources/teams/#{team.id}/team_members?view=show"
        page.driver.browser.header("Turbo-Frame", true)
        visit url
      end

      it "does not display breadcrumbs" do
        expect(page).to_not have_selector ".breadcrumbs"
      end

      it "does not display a back button" do
        expect(page).to_not have_selector "div[data-target='panel-tools'] a", text: "Go back"
      end
    end
  end

  describe "on associations" do
    it "show" do
      url = avo.resources_project_path(project, via_record_id: admin, via_resource_class: Avo::Resources::User)
      visit url

      breadcrumbs = find(".breadcrumbs")
      expect(breadcrumbs).to have_link "Home"
      expect(breadcrumbs).to have_link "Users"
      expect(breadcrumbs).to have_link admin.name
      expect(breadcrumbs).to_not have_link "Projects"
      expect(breadcrumbs).to have_text "Projects"
      expect(breadcrumbs).to_not have_link project.name
      expect(breadcrumbs).to have_text project.name
      expect(breadcrumbs).to_not have_link "Details"
      expect(breadcrumbs).to have_text "Details"
    end

    it "edit" do
      url = avo.edit_resources_project_path(project, via_record_id: admin, via_resource_class: Avo::Resources::User)
      visit url

      breadcrumbs = find(".breadcrumbs")
      expect(breadcrumbs).to have_link "Home"
      expect(breadcrumbs).to have_link "Users"
      expect(breadcrumbs).to have_link admin.name
      expect(breadcrumbs).to_not have_link "Projects"
      expect(breadcrumbs).to have_text "Projects"
      expect(breadcrumbs).to have_link project.name
      expect(breadcrumbs).to_not have_link "Edit"
      expect(breadcrumbs).to have_text "Edit"
    end

    it "new" do
      url = avo.new_resources_project_path(via_record_id: admin, via_resource_class: Avo::Resources::User, via_relation: :users, via_relation_class: "User")
      visit url

      breadcrumbs = find(".breadcrumbs")
      expect(breadcrumbs).to have_link "Home"
      expect(breadcrumbs).to have_link "Users"
      expect(breadcrumbs).to have_link admin.name
      expect(breadcrumbs).to_not have_link "Projects"
      expect(breadcrumbs).to have_text "Projects"
      expect(breadcrumbs).to_not have_link "New"
      expect(breadcrumbs).to have_text "New"
    end
  end
end
