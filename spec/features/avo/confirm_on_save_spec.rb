# frozen_string_literal: true

require "rails_helper"

RSpec.feature "ConfirmOnSave", type: :feature do
  context "edit" do
    let!(:store) { create :store, name: store_name }
    let(:store_name) { "original name" }
    let(:name_field) { "store[name]" }
    let(:changed_name) { "new name" }

    describe "when saving the record" do
      it "confirms the operation" do
        visit "/admin/resources/stores/#{store.id}/edit"

        save

        expect(page).to have_selector("#turbo-confirm button[value="confirm"]")
      end

      it "completes the operation on confirmation" do
        visit "/admin/resources/stores/#{store.id}/edit"

        expect(page).to have_field name_field

        fill_in "store[name]", with: changed_name

        save

        accept_custom_alert do
          click_on "Yes, I"m sure"
        end

        expect(store.reload.name).to eq(changed_name)
      end

      it "does not complete the operation on denial" do
        visit "/admin/resources/stores/#{store.id}/edit"

        expect(page).to have_field name_field

        fill_in "store[name]", with: changed_name

        save

        accept_custom_alert do
          click_on "No, cancel"
        end

        expect(page).not_to have_selector(".button-spinner")
        expect(find_field_value_element("name")).to have_text changed_name
        expect(store.name).to eq(store_name)
      end
    end
  end
end
