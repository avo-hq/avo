require "rails_helper"

RSpec.describe "Record previews", type: :system do
  let!(:team) { create :team, team_members: [admin], description: "xyz123", color: "#cc00cc" }

  it "opens the preview" do
    visit "/admin/resources/teams"
    within find("[data-resource-id='#{team.id}'] [data-field-id='preview'][data-field-type='preview']") do
      expect(page).to have_css("svg.block.h-6.text-gray-600")
      find('a[title="View team"]').hover
    end

    expect(page).to have_css("#tippy-1")

    within find("#tippy-1") do
      expect(page).to have_text "DESCRIPTION"
      expect(page).to have_text "xyz123"
      expect(page).to have_text "COLOR"
      expect(page).to have_text "#cc00cc"
    end
  end
end
