require "rails_helper"

def set_policy(result)
  eval <<-HEREDOC
    class TeamPolicy < ApplicationPolicy
      # Team members association
      def create_team_members?
        #{result}
      end

      def destroy_team_members?
        #{result}
      end

      def view_team_members?
        #{result}
      end

      def edit_team_members?
        #{result}
      end

      def attach_team_members?
        #{result}
      end

      def detach_team_members?
        #{result}
      end

      def act_on_team_members?
        #{result}
      end

      class Scope < ApplicationPolicy::Scope
        def resolve
          scope.all
        end
      end
    end
  HEREDOC
end

RSpec.describe 'Avo::TeamsController', type: :system do
  let!(:team) { create :team }
  let!(:user) { create :user }
  let!(:team_member) { team.team_members << user }


  before do
    set_policy has_access
  end

  context 'all false' do
    let!(:has_access) { false }

    describe ".index" do
      it "returns the scoped results" do
        visit "/admin/resources/teams/#{team.id}/team_members?turbo_frame=has_many_field_show_team_members"

        expect(page).not_to have_selector("[data-controller='toggle-panel actions-picker']")
        expect(page).not_to have_selector("[data-target='create']")
        expect(page).not_to have_selector("[data-target='attach']")
        expect(page).not_to have_selector("[data-target='control:view']")
        expect(page).not_to have_selector("[data-target='control:edit']")
        expect(page).not_to have_selector("[data-target='control:detach']")
        expect(page).not_to have_selector("[data-target='control:destroy']")
      end
    end
  end

  context 'all true' do
    let!(:has_access) { true }

    describe ".index" do
      it "returns the scoped results" do
        visit "/admin/resources/teams/#{team.id}/team_members?turbo_frame=has_many_field_show_team_members"

        expect(page).to have_selector("[data-controller='toggle-panel actions-picker']")
        expect(page).to have_selector("[data-target='create']")
        expect(page).to have_selector("[data-target='attach']")
        expect(page).to have_selector("[data-target='control:view']")
        expect(page).to have_selector("[data-target='control:edit']")
        expect(page).to have_selector("[data-target='control:detach']")
        expect(page).to have_selector("[data-target='control:destroy']")
      end
    end
  end
end
