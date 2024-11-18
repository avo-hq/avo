require "rails_helper"

RSpec.describe "RadioField", type: :feature do
  describe "when size is present" do
    let!(:fish) { create :fish, size: "small" }

    context "index" do
      it "displays the fish name" do
        visit "/admin/resources/fish"

        expect(page).to have_text "Size"
        expect(page).to have_text fish.size
      end
    end

    context "show" do
      it "displays the fish size" do
        visit "/admin/resources/fish/#{fish.id}"

        expect(page).to have_text fish.size
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
end
