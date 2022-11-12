require "rails_helper"

RSpec.describe "PersistentAction", type: :system do
  describe "persistent action" do
    context "index" do
      it "dummy action normal behaviour" do
        visit "/admin/resources/users"

        click_on "Actions"
        click_on "Dummy action"
        click_on "Run"

        expect(page).to have_text "Success response ✌️"
        expect(page).to have_text "Warning response ✌️"
        expect(page).to have_text "Info response ✌️"
        expect(page).to have_text "Error response ✌️"
      end

      it "show messages, persist and keep form" do
        visit "/admin/resources/users"

        click_on "Actions"
        click_on "Dummy action"
        check("Persistent")
        fill_in "fields_persistent_text", with: "Persistent =)"
        click_on "Run"

        expect(page).to have_text "Persistent success response ✌️"
        expect(page).to have_text "Persistent warning response ✌️"
        expect(page).to have_text "Persistent info response ✌️"
        expect(page).to have_text "Persistent error response ✌️"
        expect(page).to have_field type: "text", id: "fields_persistent_text", with: "Persistent =)"

        uncheck("Persistent")
        click_on "Run"

        expect(page).to have_text "Success response ✌️"
        expect(page).to have_text "Warning response ✌️"
        expect(page).to have_text "Info response ✌️"
        expect(page).to have_text "Error response ✌️"
      end
    end
  end
end
