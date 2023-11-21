require "rails_helper"

RSpec.feature "InvalidField", type: :feature do
  let(:team) { create :team }
  let(:post) { create :post }

  describe "when an invalid field is declared" do
    it "shows an alert" do
      visit "/admin/resources/teams/#{team.id}"

      expect(page.body).to include "There's an invalid field configuration for this resource."
      expect(page.body).to include "field :invalid, as: :invalid_field"
    end
  end

  describe "when no invalid field is declared" do
    it "shows an alert" do
      visit "/admin/resources/posts/#{post.id}"

      expect(page.body).not_to include "There's an invalid field configuration for this resource."
      expect(page.body).not_to include "field :invalid, as: invalid_field"
    end
  end
end
