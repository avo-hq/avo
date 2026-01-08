require "rails_helper"

RSpec.feature "Breadcrumbs", type: :feature do
  let!(:project) { create :project, users: [admin] }
  let!(:url) { "/admin/resources/projects/#{project.id}/edit" }
  let(:breadcrumbs) { find(".breadcrumbs") }

  def initials_for(record)
    record.name.to_s.split(" ").map(&:first).join("").first(2).upcase
  end

  before do
    visit url
  end

  describe "with breadcrumbs" do
    it do
      login_as admin
      visit url

      # Verify that the text includes all breadcrumbs
      expect(breadcrumbs).to have_text("Home")
      expect(breadcrumbs).to have_text("Projects")
      expect(breadcrumbs).to have_text(project.name)
      expect(breadcrumbs).to have_text("Edit")

      # Ensure the breadcrumbs are in the correct order
      expect(breadcrumbs.text).to match(/Home.*Projects.*#{project.name}.*Edit/)
    end

    describe "with avatar" do
      let!(:event) { create(:event, :with_avatar) }

      it "displays avatar" do
        visit avo.resources_event_path(event)

        expect(breadcrumbs.text).to eq "Home / E Events /\n#{event.name} / Details"
        expect(breadcrumbs).to have_link "Home"
        expect(breadcrumbs).to have_link "Events"
        expect(breadcrumbs).to have_text event.name

        # Find the avatar image
        avatar = find(".breadcrumbs .breadcrumb-element__avatar img")
        expect(avatar["src"]).to eq(main_app.url_for(event.avatar))
      end
    end
  end

  describe "on a custom tool" do
    let!(:url) { "/admin/custom_tool" }

    it do
      visit url

      # Verify that the text includes all breadcrumbs
      expect(breadcrumbs).to have_text("Home")

      # Ensure the breadcrumbs are in the correct order
      expect(breadcrumbs.text).to match(/Home/)
    end
  end

  describe "on a has_and_belongs_to_many turbo frame" do
    let!(:user) { create(:user) }
    let!(:team) { create(:team) }

    context "when HTML request" do
      it "displays breadcrumbs" do
        url = "/admin/resources/users/#{user.slug}/teams?view=show"
        visit url

        expect(page).to have_selector ".breadcrumbs"
        expect(breadcrumbs.text).to eq "Home / U Users / #{initials_for(user)} #{user.name} / T Teams"

        expect(breadcrumbs).to have_link "Home"
        expect(breadcrumbs).to have_link "Users"
        expect(breadcrumbs).to have_link user.name.to_s
        expect(breadcrumbs).to_not have_link "Teams"
      end

      it "displays breadcrumbs" do
        url = "/admin/resources/teams/#{team.id}/team_members?view=show"
        visit url

        expect(page).to have_selector ".breadcrumbs"
        expect(breadcrumbs.text).to eq "Home / T Teams / #{initials_for(team)} #{team.name} / U Users"

        expect(breadcrumbs).to have_link "Home"
        expect(breadcrumbs).to have_link "Teams"
        expect(breadcrumbs).to have_link team.name.to_s
        expect(breadcrumbs).to_not have_link "Users"
      end

      it "displays a back button" do
        url = "/admin/resources/teams/#{team.id}/team_members?view=show"
        visit url

        expect(page).to have_selector ".header__controls a[href='/admin/resources/teams/#{team.id}']", text: "Go back"
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
        expect(page).to_not have_selector ".header__controls a", text: "Go back"
      end
    end
  end

  describe "on associations" do
    it "show" do
      url = avo.resources_project_path(project, via_record_id: admin, via_resource_class: Avo::Resources::User)
      visit url

      expect(breadcrumbs.text).to eq "Home / U Users / #{initials_for(admin)} #{admin.name} / P Projects / #{initials_for(project)} #{project.name} / Details"
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
