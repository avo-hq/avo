require "rails_helper"

RSpec.describe "TextField", type: :system do
  describe "with regular input" do
    let!(:user) { create :user }

    context "index" do
      it "displays the users first name" do
        visit "/admin/resources/users"

        expect(page).to have_text user.first_name
      end
    end

    context "show" do
      it "displays the users first name" do
        visit "/admin/resources/users/#{user.id}"

        expect(page).to have_text user.first_name
      end
    end

    context "edit" do
      it "has the users name pre-filled" do
        visit "/admin/resources/users/#{user.id}/edit"

        expect(find_field("user_first_name").value).to eq user.first_name
      end

      it "changes the users name" do
        visit "/admin/resources/users/#{user.id}/edit"

        fill_in "user_first_name", with: "Jack Jack Jack"

        click_on "Save"
        wait_for_loaded

        expect(current_path).to eql "/admin/resources/users/#{user.id}"
        expect(page).to have_text "Jack Jack Jack"
      end
    end
  end
end
