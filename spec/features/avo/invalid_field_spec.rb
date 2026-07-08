require "rails_helper"

RSpec.feature "InvalidField", type: :feature do
  let(:team) { create :team }
  let(:post) { create :post }

  describe "when an invalid field is declared" do
    it "shows an alert" do
      visit "/admin/resources/teams/#{team.id}"

      expect(page.body).to include "Invalid field configuration"
      expect(page.body).to include "field :invalid, as: :invalid_field"
    end
  end

  describe "when no invalid field is declared" do
    it "shows an alert" do
      visit "/admin/resources/posts/#{post.to_param}"

      expect(page.body).not_to include "Invalid field configuration"
      expect(page.body).not_to include "field :invalid, as: invalid_field"
    end
  end
end
