require "rails_helper"

RSpec.describe "HelpText", type: :system do
  describe "with regular input" do
    let!(:user) { create :user }

    context "edit" do
      it "checks for help text visibility" do
        visit "/admin/resources/users/#{user.id}/edit"

        expect(find_field_element(:custom_css)).to have_text("This enables you to edit the user's custom styles.")
      end

      it "checks for help html visibility" do
        visit "/admin/resources/users/#{user.id}/edit"

        expect(find_field_element(:password)).to have_text("You may verify the password strength here.")
        expect(find_field_element(:password)).to have_selector('a[href="http://www.passwordmeter.com/"]')
      end
    end
  end
end
