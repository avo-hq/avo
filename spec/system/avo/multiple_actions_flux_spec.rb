require "rails_helper"

RSpec.describe "Multiple Actions Flux", type: :system do
  let!(:user) { create :user, first_name: "Spec", last_name: "User", active: false }

  describe "multiple actions flux" do
    context "index" do
      it "present the first action and render the second one with data from arguments" do
        visit "/admin/resources/users"

        within("tr[data-resource-name=\"users\"][data-resource-id=\"#{user.id}\"][data-controller=\"item-selector\"]") do
          find(:css, 'input[type="checkbox"][data-action="input->item-selector#toggle input->item-select-all#selectRow"]', match: :first).set(true)
        end

        click_on "Actions"
        within("[data-toggle-panel-target='panel']") do
          click_on "Update"
        end

        within(find("[role='dialog']")) do
          expect(page).to have_text "FIRST NAME"
          expect(page).to have_text "LAST NAME"
          expect(page).to have_text "USER EMAIL"
          expect(page).to have_text "ACTIVE"
          expect(page).to have_text "ADMIN"
        end

        check("First name")
        check("Last name")
        check("Admin")

        within(find("[role='dialog']")) do
          click_on "Run"
          expect(page).to have_text "FIRST NAME"
          expect(page).to have_text "LAST NAME"
          expect(page).not_to have_text "USER EMAIL"
          expect(page).not_to have_text "ACTIVE"
          expect(page).to have_text "ADMIN"
        end

        expect(page).to have_text "FIRST NAME"
        expect(page).to have_text "LAST NAME"
        expect(page).to have_text "USER EMAIL"
        expect(page).to have_text "ACTIVE"
        expect(page).to have_text "ADMIN"

        fill_in "fields_first_name", with: "1"
        fill_in "fields_last_name", with: "2"
        check "Admin"

        click_on "Run"

        sleep 0.1

        expect(page).to have_text "User(s) updated!"
        expect(user.reload.first_name).to eq "1"
        expect(user.last_name).to eq "2"
        expect(user.is_admin?).to eq true
      end
    end
  end
end
