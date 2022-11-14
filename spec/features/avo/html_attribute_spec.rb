require "rails_helper"

RSpec.feature "HtmlAttributes", type: :feature do
  let(:product) { create :product }

  context "on show" do
    it "renders the html attributes" do
      visit avo.resources_product_path product

      expect(field_wrapper(:title).find('[data-slot="value"]')[:class]).to include "bg-gray-50 !text-pink-600"
      expect(field_wrapper(:title).find('[data-slot="label"]')[:class]).to include "bg-gray-50 !text-pink-600"
    end
  end

  context "on index" do
    let(:red_team) { create :team, color: "#FF0000" }
    let(:green_team) { create :team, color: "#00FF00" }
    let(:user) { create :user }

    before do
      # Only teams with members show on index page
      [red_team, green_team].each do |team|
        team.team_members << user
      end
    end

    it "evaluates the block syntax" do
      visit avo.resources_teams_path

      expect(field_element_by_resource_id("name", red_team.id)["style"]).to match(/color: #FF0000/)
      expect(field_element_by_resource_id("name", green_team.id)["style"]).to match(/color: #00FF00/)
    end
  end
end
