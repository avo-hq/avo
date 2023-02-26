require "rails_helper"

RSpec.feature "Authorizations", type: :feature do
  let(:team) { create :team, team_members: [admin] }

  it "checks for the field authorization with the Team instance" do
    allow(TestBuddy).to receive(:hi).and_call_original
    expect(TestBuddy).to receive(:hi).with("view_team_members?->Team").at_least :once

    visit "/admin/resources/teams/#{team.id}"
  end

  it "checks authorization for each individually" do
    allow(TestBuddy).to receive(:hi).and_call_original

    # Some checks run on the parent record
    expect(TestBuddy).to receive(:hi).with("create_team_members?->Team").at_least :once
    expect(TestBuddy).to receive(:hi).with("attach_team_members?->Team").at_least :once
    expect(TestBuddy).to receive(:hi).with("act_on_team_members?->Team").at_least :once

    # Some checks run on the child record
    expect(TestBuddy).to receive(:hi).with("show_team_members?->User").at_least :once
    expect(TestBuddy).to receive(:hi).with("destroy_team_members?->User").at_least :once
    expect(TestBuddy).to receive(:hi).with("edit_team_members?->User").at_least :once
    expect(TestBuddy).to receive(:hi).with("detach_team_members?->User").at_least :once

    visit "/admin/resources/teams/#{team.id}/team_members?turbo_frame=has_many_field_show_team_members"

    expect(page).to have_text admin.first_name
    expect(page).to have_text admin.last_name
  end

  describe "association scope" do
    let(:adrian) { create :user, first_name: "Adrian" }
    let(:john) { create :user, first_name: "John" }
    let(:team) { create :team, team_members: [adrian, john] }

    it "applies the association scope to the query" do
      # For this test override the scope resolve function
      # rubocop:disable Lint/ConstantDefinitionInBlock
      class StubbedScope < UserPolicy::Scope
        def resolve
          if scope != Team
            scope.where("first_name ILIKE ?", "%j%")
          else
            scope
          end
        end
      end
      # rubocop:enable Lint/ConstantDefinitionInBlock
      allow_any_instance_of(Avo::Services::AuthorizationClients::PunditClient).to receive(:scope_for_policy_class).and_return StubbedScope

      visit "/admin/resources/teams/#{team.id}/team_members?turbo_frame=has_many_field_show_team_members"

      expect(page).not_to have_text("Adrian")
      expect(page).to have_text("John")
    end
  end
end
