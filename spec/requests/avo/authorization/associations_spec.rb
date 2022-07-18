require "rails_helper"

RSpec.describe 'Avo::TeamsController', type: :feature do
  let!(:team) { create :team }
  let!(:user) { create :user }
  let!(:team_member) { team.team_members << user }

  context 'all false' do
    describe ".index" do
      it "returns the scoped results" do
        allow_any_instance_of(TeamPolicy).to receive(:view_team_members?).and_return false

        visit "/admin/resources/teams/#{team.id}/team_members?turbo_frame=has_many_field_show_team_members"

        expect(current_path).to eql avo_home_path
      end
    end

    describe ".team_members related" do
      it "returns the scoped results" do
        # Test for false-positives and make sure UserPolicy.show doesn't return true
        allow_any_instance_of(UserPolicy).to receive(:show?).and_return false

        allow_any_instance_of(TeamPolicy).to receive(:view_team_members?).and_return true
        allow_any_instance_of(TeamPolicy).to receive(:show_team_members?).and_return false
        allow_any_instance_of(TeamPolicy).to receive(:create_team_members?).and_return false
        allow_any_instance_of(TeamPolicy).to receive(:destroy_team_members?).and_return false
        allow_any_instance_of(TeamPolicy).to receive(:edit_team_members?).and_return false
        allow_any_instance_of(TeamPolicy).to receive(:attach_team_members?).and_return false
        allow_any_instance_of(TeamPolicy).to receive(:detach_team_members?).and_return false
        allow_any_instance_of(TeamPolicy).to receive(:act_on_team_members?).and_return false

        visit "/admin/resources/teams/#{team.id}/team_members?turbo_frame=has_many_field_show_team_members"

        expect(current_path).to eql "/admin/resources/teams/#{team.id}/team_members"

        resource_index = find('[data-component="resources-index"]')

        expect(resource_index).not_to have_selector("[data-controller='toggle-panel actions-picker']")
        expect(resource_index).not_to have_selector("[data-target='create']")
        expect(resource_index).not_to have_selector("[data-target='attach']")
        expect(resource_index).not_to have_selector("[data-target='control:view']")
        expect(resource_index).not_to have_selector("[data-target='control:edit']")
        expect(resource_index).not_to have_selector("[data-target='control:detach']")
        expect(resource_index).not_to have_selector("[data-target='control:destroy']")
      end
    end
  end

  context 'all true' do
    describe ".index" do
      it "returns the scoped results" do
        allow_any_instance_of(TeamPolicy).to receive(:view_team_members?).and_return true
        allow_any_instance_of(TeamPolicy).to receive(:show_team_members?).and_return true
        allow_any_instance_of(TeamPolicy).to receive(:create_team_members?).and_return true
        allow_any_instance_of(TeamPolicy).to receive(:destroy_team_members?).and_return true
        allow_any_instance_of(TeamPolicy).to receive(:edit_team_members?).and_return true
        allow_any_instance_of(TeamPolicy).to receive(:attach_team_members?).and_return true
        allow_any_instance_of(TeamPolicy).to receive(:detach_team_members?).and_return true
        allow_any_instance_of(TeamPolicy).to receive(:act_on_team_members?).and_return true

        visit "/admin/resources/teams/#{team.id}/team_members?turbo_frame=has_many_field_show_team_members"

        expect(current_path).to eql "/admin/resources/teams/#{team.id}/team_members"


        resource_index = find('[data-component="resources-index"]')
        expect(resource_index).to have_selector("[data-controller='toggle-panel actions-picker']")
        expect(resource_index).to have_selector("[data-target='create']")
        expect(resource_index).to have_selector("[data-target='attach']")
        expect(resource_index).to have_selector("[data-target='control:view']")
        expect(resource_index).to have_selector("[data-target='control:edit']")
        expect(resource_index).to have_selector("[data-target='control:detach']")
        expect(resource_index).to have_selector("[data-target='control:destroy']")
      end
    end
  end
end
