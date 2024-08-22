# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Custom components", type: :feature do
  describe "symbol" do
    before do
      Avo::Resources::User.components = {
        resource_index_component: Avo::ForTest::ResourceIndexComponent,
        resource_show_component: "Avo::ForTest::ResourceShowComponent",
        resource_edit_component: "Avo::ForTest::ResourceEditComponent",
        resource_new_component: Avo::ForTest::ResourceNewComponent
      }
    end

    it "index" do
      visit avo.resources_users_path

      expect(page).to have_text("Custom index component here!")
    end

    it "show" do
      visit avo.resources_user_path(admin)

      expect(page).to have_text("Custom show component here!")
    end

    it "new" do
      visit avo.new_resources_user_path

      expect(page).to have_text("Custom new component here!")
    end

    it "edit" do
      visit avo.edit_resources_user_path(admin)

      expect(page).to have_text("Custom edit component here!")
    end
  end

  describe "class" do
    before do
      Avo::Resources::User.components = {
        "Avo::Views::ResourceIndexComponent": Avo::ForTest::ResourceIndexComponent,
        "Avo::Views::ResourceShowComponent": "Avo::ForTest::ResourceShowComponent",
        "Avo::Views::ResourceEditComponent": "Avo::ForTest::ResourceEditComponent",
        "Avo::Index::GridItemComponent": "Avo::ForTest::GridItemComponent"
      }
    end

    it "index" do
      visit avo.resources_users_path

      expect(page).to have_text("Custom index component here!")
    end

    it "grid item component" do
      visit avo.resources_users_path(view_type: :grid)

      expect(page).to have_text("Custom grid item component here!")
    end

    it "show" do
      visit avo.resources_user_path(admin)

      expect(page).to have_text("Custom show component here!")
    end

    # Impossible to specify for new, only for edit.
    it "new" do
      visit avo.new_resources_user_path

      expect(page).to have_text("Custom edit component here!")
    end

    it "edit" do
      visit avo.edit_resources_user_path(admin)

      expect(page).to have_text("Custom edit component here!")
    end
  end
end
