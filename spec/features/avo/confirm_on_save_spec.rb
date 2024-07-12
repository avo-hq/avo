require "rails_helper"

RSpec.feature "ConfirmOnSave", type: :feature do
  context "edit" do
    let!(:store) { create :store , name: 'original name'}

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
        
        expect(store.reload.name).to eq('Changed Name')
      end

      it "does not complete the operation on denial" do
        visit "/admin/resources/stores/#{store.id}/edit"

        expect(page).to have_field "store[name]"

        fill_in "store[name]", with: "Changed Name"

        save

        accept_custom_alert do
          click_on "No, cancel"
        end
        expect(page).not_to have_selector('.button-spinner') 
        expect(find_field_value_element("name")).to have_text "Changed Name"
        expect(store.name).to eq('original name')
      end
    end
  end
end
