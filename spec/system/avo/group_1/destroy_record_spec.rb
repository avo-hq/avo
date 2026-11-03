require "rails_helper"

RSpec.feature "DestroyRecord", type: :system do
  describe "foreign key constraints" do
    let!(:user) { create :user }
    let!(:comment) { create :comment, user: user }

    it "raises error" do
      url = "/admin/resources/users/#{user.slug}"
      visit url

      expect {
        accept_custom_alert do
          click_on "Delete"
        end
        wait_for_loaded
        sleep 0.2
      }.not_to change(User, :count)

      expect(current_path).to eq url
      expect(page).to have_text "PG::ForeignKeyViolation"
    end
  end

  describe "confirmation lists the dependents destroyed with the record" do
    let!(:team) { create :team }
    let(:warning) { "This will also delete 1 admin membership." }

    it "counts only the records the association would destroy" do
      TeamMembership.create!(team: team, user: create(:user), level: :admin)
      TeamMembership.create!(team: team, user: create(:user), level: :member)

      visit "/admin/resources/teams/#{team.id}"
      click_on "Delete"

      expect(page).to have_css("#turbo-confirm[open]", text: "Are you sure?")
      expect(page).to have_css("#turbo-confirm[open]", text: warning)
    end

    it "clears the loading line when nothing else would be deleted" do
      visit "/admin/resources/teams/#{team.id}"
      click_on "Delete"

      expect(page).to have_css("#turbo-confirm[open]", text: "Are you sure?")
      expect(page).to have_no_css("#turbo-confirm [data-dependents]", visible: true)
    end

    # Index links carry query params, which Turbo moves off the URL of the form it builds from the link.
    it "names them from an index row" do
      TeamMembership.create!(team: team, user: create(:user), level: :admin)

      visit "/admin/resources/teams"
      find("tr[data-resource-id='#{team.id}']").hover
      find("tr[data-resource-id='#{team.id}'] [data-control='destroy']").click

      expect(page).to have_css("#turbo-confirm[open]", text: warning)
    end
  end
end
