require "rails_helper"

RSpec.describe "Destroy a record from the index", type: :system do
  let!(:doomed_team) { create :team, name: "alpha doomed" }
  let!(:kept_team) { create :team, name: "alpha kept" }
  let!(:filtered_out_team) { create :team, name: "beta team" }

  it "returns to the index with the same filters" do
    # MembersFilter defaults to teams with members, so turn it off to see the new teams.
    encoded_filters = Avo::Filters::BaseFilter.encode_filters(
      "Avo::Filters::MembersFilter" => {"has_members" => false},
      "Avo::Filters::NameFilter" => "alpha"
    )
    visit "/admin/resources/teams?view_type=table&encoded_filters=#{CGI.escape(encoded_filters)}"

    expect(page).to have_text "alpha kept"
    expect(page).not_to have_text "beta team"

    doomed_row = find("tr[data-resource-id='#{doomed_team.to_param}']")
    # Teams only show row controls on hover.
    doomed_row.hover
    accept_custom_alert do
      doomed_row.find("[data-control='destroy']").click
    end
    wait_for_loaded

    expect(page).to have_current_path(/encoded_filters=/)
    expect(page).to have_text "alpha kept"
    expect(page).not_to have_text "alpha doomed"
    expect(page).not_to have_text "beta team"
  end
end
