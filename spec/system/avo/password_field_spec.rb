require "rails_helper"

RSpec.describe "PasswordField", type: :system do
  describe "reveal true" do
    context "create" do
      it "password reveal button is toggling" do
        visit "/admin/resources/users/new"

        expect(page).to have_field type: "password", id: "user_password_confirmation"
        find("[data-action='password-visibility#toggle']").click
        expect(page).to have_field type: "text", id: "user_password_confirmation"
      end
    end
  end
end
