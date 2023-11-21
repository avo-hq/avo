require "rails_helper"

RSpec.describe "Action link", type: :system do
  let!(:city) { create :city, name: "Action link City" }

  describe "on computed field" do
    context "index" do
      it "name link opens update action" do
        visit "/admin/resources/cities"

        expect(page).to have_text "Action link City"

        click_on "Action link City"

        within(find("[role='dialog']")) do
          expect(page).to_not have_text "POPULATION"
          expect(page).to have_text "NAME"
        end

        fill_in "fields_name", with: "Action link Updated City"

        run_action

        expect(page).to have_text "City updated!"
        expect(page).to have_text "Action link Updated City "
        expect(page).not_to have_text "Action link City"
      end
    end
  end
end
