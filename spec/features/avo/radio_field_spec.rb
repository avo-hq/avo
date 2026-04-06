require "rails_helper"

RSpec.describe "RadioField", type: :feature do
  describe "when size is present" do
    let!(:fish) { create :fish, size: "small" }

    context "index" do
      it "displays the fish name" do
        visit "/admin/resources/fish"

        expect(page).to have_text "Size"
        expect(page).to have_text "Small"
      end
    end

    context "show" do
      it "displays the fish size" do
        visit "/admin/resources/fish/#{fish.id}"

        expect(page).to have_text "Small"
      end
    end

    context "edit" do
      it "changes the fish size" do
        visit "/admin/resources/fish/#{fish.id}/edit"

        expect(Avo.field_manager.fields).to include(
          {name: "radio", class: Avo::Fields::RadioField},
          {name: "pluggy_radio", class: Pluggy::Fields::RadioField}
        )

        expect(page).to have_checked_field "fish_size_small"
        expect(page).to_not have_checked_field "fish_size_medium"
        expect(page).to_not have_checked_field "fish_size_large"

        find("#fish_size_large").click

        expect(page).to_not have_checked_field "fish_size_small"
        expect(page).to_not have_checked_field "fish_size_medium"
        expect(page).to have_checked_field "fish_size_large"

        save

        fish.reload

        expect(fish.size).to eq "large"
      end
    end
  end

  describe "when size is nil" do
    let!(:fish) { create :fish, size: nil }

    context "edit" do
      it "does not check radio buttons" do
        visit "/admin/resources/fish/#{fish.id}/edit"

        expect(page).to_not have_checked_field "fish_size_small"
        expect(page).to_not have_checked_field "fish_size_medium"
        expect(page).to_not have_checked_field "fish_size_large"
      end
    end
  end

  describe "display_value" do
    let!(:fish) { create :fish, size: "small" }

    context "when display_value is false (default)" do
      it "shows the label on index" do
        visit "/admin/resources/fish"

        expect(page).to have_text "Small"
      end

      it "shows the label on show" do
        visit "/admin/resources/fish/#{fish.id}"

        expect(page).to have_text "Small"
      end
    end

    context "when display_value is true" do
      before(:all) do
        Avo::Resources::Fish.with_temporary_items do
          field :id, as: :id
          field :name, as: :text
          field :size, as: :radio, options: {small: "Small", medium: "Medium", large: "Large"}, display_value: true
        end
      end

      after(:all) do
        Avo::Resources::Fish.restore_items_from_backup
      end

      it "shows the raw value on index" do
        visit "/admin/resources/fish"

        expect(page).to have_text "small"
      end

      it "shows the raw value on show" do
        visit "/admin/resources/fish/#{fish.id}"

        expect(page).to have_text "small"
      end
    end
  end

  describe "display_as tabs" do
    let!(:fish) { create :fish, size: "small" }

    before(:all) do
      Avo::Resources::Fish.with_temporary_items do
        field :id, as: :id
        field :name, as: :text
        field :size, as: :radio, options: {small: "Small", medium: "Medium", large: "Large"}, display_as: :tabs
      end
    end

    after(:all) do
      Avo::Resources::Fish.restore_items_from_backup
    end

    context "edit" do
      it "renders as switcher tabs" do
        visit "/admin/resources/fish/#{fish.id}/edit"

        expect(page).to have_css ".tabs--switcher"
        expect(page).to have_text "Small"
        expect(page).to have_text "Medium"
        expect(page).to have_text "Large"
      end

      it "selects the correct option" do
        visit "/admin/resources/fish/#{fish.id}/edit"

        expect(page).to have_checked_field "fish_size_small", visible: :all
        expect(page).to_not have_checked_field "fish_size_large", visible: :all
      end

      it "changes selection via tab click" do
        visit "/admin/resources/fish/#{fish.id}/edit"

        find("label", text: "Large").click

        expect(page).to have_checked_field "fish_size_large", visible: :all
        expect(page).to_not have_checked_field "fish_size_small", visible: :all

        save

        fish.reload
        expect(fish.size).to eq "large"
      end
    end
  end

  describe "on actions" do
    it "display options" do
      visit avo.resources_actions_show_path(resource_name: "users", action_id: "Avo::Actions::Sub::DummyAction")

      expect(page).to have_text("Small Option")
      expect(page).to have_text("Medium Option")
      expect(page).to have_checked_field("fields_size_medium")
      expect(page).to have_text("Large Option")

      find("label[for='fields_size_large']").click
      expect(page).not_to have_checked_field("fields_size_medium")
      expect(page).to have_checked_field("fields_size_large")
    end
  end
end
