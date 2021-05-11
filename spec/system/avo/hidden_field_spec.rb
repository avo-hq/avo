require "rails_helper"

RSpec.describe "HiddenField", type: :system do
  describe "without input" do
    let!(:user) { create :user }

    context "edit" do
      it "has the hidden field empty" do
        visit "/admin/resources/users/#{user.id}/edit"

        expect(find("input#user_team_id[type='hidden']", visible: false).value).to be_empty
      end
    end
  end

  describe "with regular input" do
    let!(:user) { create :user, team_id: 10 }

    context "edit" do
      it "has the hidden field" do
        visit "/admin/resources/users/#{user.id}/edit"

        expect(find("input#user_team_id[type='hidden']", visible: false).value).to eq "10"
      end
    end
  end
end
