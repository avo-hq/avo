require "rails_helper"

RSpec.feature "ConfirmOnSave", type: :feature do
  context "edit" do
    let!(:store) { create :store , name: nil}

    describe "when saving the record" do
      it "confirms the operation" do
        visit "/admin/resources/stores/#{store.id}/edit"

        save
      
        expect(page).to have_selector('#turbo-confirm button[value="confirm"]')
      end

      it "completes the operation on confirmation" do
        visit "/admin/resources/stores/#{store.id}/edit"

        expect(page).to have_field "store[name]"

        fill_in "store[name]", with: "Changed Name"

        save

        accept_custom_alert do
          click_on "Yes, I'm sure"
        end
        
        expect(find_field_value_element("name")).to have_text "Changed Name"
      end
    end
  end
end