require "rails_helper"

RSpec.feature "Breadcrumbs", type: :feature do
  let!(:project) { create :project }
  let!(:url) { "/admin/resources/projects/#{project.id}/edit" }

  before do
    visit url
  end

  describe "with breadcrumbs" do
    it do
      login_as admin
      visit url

      # Find the breadcrumbs container
      breadcrumbs = find('.breadcrumbs')

      # Verify that the text includes all breadcrumbs
      expect(breadcrumbs).to have_text('Home')
      expect(breadcrumbs).to have_text('Projects')
      expect(breadcrumbs).to have_text(project.name)
      expect(breadcrumbs).to have_text('Edit')

      # Ensure the breadcrumbs are in the correct order
      expect(breadcrumbs.text).to match(/Home.*Projects.*#{project.name}.*Edit/)
    end
  end

  describe "on a custom tool" do
    let!(:url) { "/admin/custom_tool" }

    it do
      visit url

      # Find the breadcrumbs container
      breadcrumbs = find('.breadcrumbs')

      # Verify that the text includes all breadcrumbs
      expect(breadcrumbs).to have_text('Home')

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
end
