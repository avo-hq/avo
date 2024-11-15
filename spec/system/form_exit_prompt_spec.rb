require "rails_helper"

RSpec.describe "form_exit_prompt", type: :system do
  let(:city) { create :city }

  context "when navigating away with unsaved changes" do
    it "prompts the user with a confirmation message and prevents navigation if the user cancels" do
      visit "/admin/resources/cities"
      click_on "Create new city"
      fill_in "city_name", with: city.name

      message = dismiss_prompt { click_on "Comments" }

      expect(message).to eq(
        "Are you sure you want to navigate away from the page? You will lose all your changes."
      )
      expect(page).to have_current_path("/admin/resources/cities/new")
    end

    it "allows navigation if the user confirms" do
      visit "/admin/resources/cities/#{city.id}"
      click_on "Edit"
      fill_in "city_name", with: "#{city.name} updated"
      accept_prompt { click_on "Comments" }

      expect(page).to have_current_path("/admin/resources/comments")
    end
  end

  context "when submitting the form" do
    it "does not prompt the user with a confirmation message" do
      visit "/admin/resources/cities"
      click_on "Create new city"
      fill_in "city_name", with: "New City"
      click_button "Save"

      expect(page).to have_current_path(%r{/admin/resources/cities/\w+$})
    end
  end

  context "when navigating away without changing anything in the form" do
    it "does not prompt the user with a confirmation message" do
      visit "/admin/resources/cities"
      click_on "Create new city"
      click_on "Comments"

      expect(page).to have_current_path("/admin/resources/comments")
    end
  end

  context "when reloading the page" do
    it "prompts the user with a confirmation message" do
      visit "/admin/resources/cities"
      click_on "Create new city"
      fill_in "city_name", with: city.name

      message = accept_prompt { page.refresh }

      expect(message).to eq("")
    end
  end

  context "when form is reverted to clean state" do
    it "does not prompt the user with a confirmation message" do
      visit "/admin/resources/cities/#{city.id}"
      click_on "Edit"
      fill_in "city_name", with: "#{city.name} updated"

      message = dismiss_prompt { click_on "Cancel" }

      expect(message).to eq(
        "Are you sure you want to navigate away from the page? You will lose all your changes."
      )

      fill_in "city_name", with: city.name
      click_on "Cancel"

      expect(page).to have_current_path(%r{/admin/resources/cities/\w+$})
    end
  end

  context "when opening modals" do
    it "does not prompt the user with a confirmation message" do
      visit "/admin/resources/cities/#{city.id}"
      click_on "Edit"
      fill_in "city_name", with: "#{city.name} updated"
      click_on "Actions"
      click_on "Dummy action city resource"

      expect(page).to have_current_path(%r{/admin/resources/cities/\w+/edit})
    end
  end
end
