require "rails_helper"

RSpec.describe "Multiple Actions Flux", type: :system do
  let!(:city) { create :city, name: "Spec City", population: 123456 }

  describe "multiple actions flux" do
    context "index" do
      it "present the first action and render the second one with data from arguments" do
        visit "/admin/resources/cities"

        expect(page).to have_text "Spec City"
        expect(page).to have_text "123456"

        find(:css, 'input[type="checkbox"][data-action="input->item-selector#toggle input->item-select-all#selectRow"]', match: :first).set(true)

        open_panel_action(action_name: "Update")

        within(find("[role='dialog']")) do
          expect(page).to have_text "POPULATION"
          expect(page).to have_text "NAME"
        end

        check("Population")

        within(find("[role='dialog']")) do
          # Don't use "run_action" because that would expect the dialog to close
          find("[data-target='submit_action']").click
          expect(page).to have_text "POPULATION"
          expect(page).to_not have_text "NAME"
        end

        expect(page).to have_text "IS CAPITAL"
        expect(page).to have_text "Spec City"
        expect(page).to have_text "123456"

        fill_in "fields_population", with: "654321"

        run_action

        expect(page).to have_text "City updated!"
        expect(page).to have_text "Spec City"
        expect(page).not_to have_text "123456"
        expect(page).to have_text "654321"
      end
    end
  end
end
