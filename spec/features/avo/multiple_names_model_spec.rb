require "rails_helper"

RSpec.feature "multiple names model", type: :feature do
  let!(:team) { create :team }
  let!(:user) { create :user }

  before do
    team.team_members << user
  end

  subject(:team_membership) {
    team.memberships.first
  }

  describe "creating a comment" do
    context "without a polymorphic association" do
      it "sets the right form_scope" do
        visit "admin/resources/memberships/#{team_membership.id}/edit"

        click_on "Save"
      end
    end
  end
end
