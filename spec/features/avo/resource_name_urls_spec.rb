require 'rails_helper'

RSpec.feature "ResourceNameUrls", type: :feature do
  let!(:user) { create :user, first_name: 'John MMM' }
  let!(:team) { create :team, name: 'Apple XXX' }
  let!(:team_membership) { team.team_members << user }

  it "loads the model configuration in the resource URL" do
    visit "/admin/resources/memberships/#{team.memberships.first.id}"

    expect(find_field_value_element(:user)).to have_text 'John MMM'
    expect(find_field_value_element(:team)).to have_text 'Apple XXX'
  end
end
