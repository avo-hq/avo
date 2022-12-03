require "rails_helper"

RSpec.feature "Authorizations", type: :feature do
  let(:team) { create :team, team_members: [admin] }

  it "checks for the field authorization with the Team instance" do
    allow(Rails.logger).to receive(:info).and_call_original
    expect(Rails.logger).to receive(:info).with("view_team_members?->Team").at_least :once

    visit "/admin/resources/teams/#{team.id}"
  end

  it "checks authorization for each individually" do
    allow(Rails.logger).to receive(:info).and_call_original

    # Some checks run on the parent record
    expect(Rails.logger).to receive(:info).with("create_team_members?->Team").at_least :once
    expect(Rails.logger).to receive(:info).with("attach_team_members?->Team").at_least :once
    expect(Rails.logger).to receive(:info).with("act_on_team_members?->Team").at_least :once

    # Some checks run on the child record
    expect(Rails.logger).to receive(:info).with("show_team_members?->User").at_least :once
    expect(Rails.logger).to receive(:info).with("destroy_team_members?->User").at_least :once
    expect(Rails.logger).to receive(:info).with("edit_team_members?->User").at_least :once
    expect(Rails.logger).to receive(:info).with("detach_team_members?->User").at_least :once

    visit "/admin/resources/teams/#{team.id}/team_members?turbo_frame=has_many_field_show_team_members"
  end
end
