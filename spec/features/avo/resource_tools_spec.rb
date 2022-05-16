require "rails_helper"

RSpec.feature "ResourceTools", type: :feature do
  let(:fish) { create :fish, name: :Salmon }

  it "displays the resource on the show page" do
    visit avo.resources_fish_path fish

    expect(page).to have_text "Below there should be an image of this fish 🐠"
    expect(page).to have_text "The fish's name is Salmon. The ID of the record is #{fish.id} and the tool's name is FishInformation."
    expect(page).to have_selector "img.rounded[src='https://images.unsplash.com/photo-1583122624875-e5621df595b3?w=1400']"
  end

  it "displays the resource on the edit page" do
    visit avo.edit_resources_fish_path fish

    expect(page).to have_text "Below there should be an image of this fish 🐠"
    expect(page).to have_text "The fish's name is Salmon. The ID of the record is #{fish.id} and the tool's name is FishInformation."
    expect(page).to have_selector "img.rounded[src='https://images.unsplash.com/photo-1583122624875-e5621df595b3?w=1400']"
  end
end
