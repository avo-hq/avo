require "rails_helper"

RSpec.describe "Reactive filters on associations", type: :system do
  let!(:user) { create :user }
  let!(:matching_team) { create :team, name: "react:test team" }
  let!(:other_team) { create :team, name: "alpha team" }

  before do
    matching_team.team_members << user
    other_team.team_members << user
  end

  # The Team resource has a NameFilter with a `react` method that returns "react:test"
  # when MembersFilter is explicitly applied with has_members: true.
  # This causes NameFilter to filter teams to those with "react:test" in the name.
  #
  # The User resource does NOT have NameFilter, so if reactive_filters wrongly uses the
  # parent resource (User), the reaction won't fire and both teams will remain visible.
  it "applies reactive filters from the associated resource" do
    encoded_filters = Avo::Filters::BaseFilter.encode_filters(
      "Avo::Filters::MembersFilter" => {"has_members" => true}
    )
    url = "/admin/resources/users/#{user.slug}/teams?turbo_frame=has_and_belongs_to_many_field_show_teams&view_type=table&encoded_filters=#{CGI.escape(encoded_filters)}"

    visit url

    expect(page).to have_text "react:test team"
    expect(page).not_to have_text "alpha team"
  end

  it "also applies reactive filters on the regular resource index" do
    encoded_filters = Avo::Filters::BaseFilter.encode_filters(
      "Avo::Filters::MembersFilter" => {"has_members" => true}
    )
    url = "/admin/resources/teams?view_type=table&encoded_filters=#{CGI.escape(encoded_filters)}"

    visit url

    expect(page).to have_text "react:test team"
    expect(page).not_to have_text "alpha team"
  end
end
