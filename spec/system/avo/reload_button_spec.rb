require "rails_helper"

RSpec.describe "Reload button", type: :system do
  describe "reload button" do
    let!(:user) { create :user, id: 39 }
    let!(:team) { create :team, id: 4 }
    let!(:review) { create :review, reviewable: team, user: user, body: "Initial review body" }
    context "Teams" do
      it "press the reload button and it will refresh the Turbo-Frame", js: true do
        visit "/admin/resources/teams/4"
        scroll_to find('turbo-frame[id="has_many_field_show_reviews"]')

        expect(page).to have_content("Initial review body")

        review.update(body: "Updated review body")

        expect(page).to have_content("Initial review body")

        find("button[data-controller='panel-refresh']").click

        expect(page).to have_content("Updated review body")
      end
    end
  end
end
