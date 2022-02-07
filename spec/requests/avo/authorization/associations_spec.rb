require "rails_helper"

RSpec.describe 'Avo::TeamsController', type: :system do
  let!(:team) { create :team }
  let!(:user) { create :user }
  let!(:team_member) { team.team_members << user }

  $team_policy_value = true
  context 'all false' do
    before :all do
      # class TeamPolicy < ApplicationPolicy
      #   # Team members association
      #   def create_team_members?
      #     $team_policy_value
      #   end

      #   def destroy_team_members?
      #     $team_policy_value
      #   end

      #   def view_team_members?
      #     $team_policy_value
      #   end

      #   def edit_team_members?
      #     $team_policy_value
      #   end

      #   def attach_team_members?
      #     $team_policy_value
      #   end

      #   def detach_team_members?
      #     $team_policy_value
      #   end

      #   def act_on_team_members?
      #     $team_policy_value
      #   end

      #   class Scope < ApplicationPolicy::Scope
      #     def resolve
      #       scope.all
      #     end
      #   end
      # end
    end
  end

  describe ".index" do
    context "when user is not admin" do
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
    # before :all do
    #   class TeamPolicy < ApplicationPolicy
    #     # Team members association
    #     def create_team_members?
    #       true
    #     end

    #     def destroy_team_members?
    #       true
    #     end

    #     def view_team_members?
    #       true
    #     end

    #     def edit_team_members?
    #       true
    #     end

    #     def attach_team_members?
    #       true
    #     end

    #     def detach_team_members?
    #       true
    #     end

    #     def act_on_team_members?
    #       true
    #     end

    #     class Scope < ApplicationPolicy::Scope
    #       def resolve
    #         scope.all
    #       end
    #     end
    #   end
    # end
  end


  describe ".index" do
    context "when user is not admin" do
      it "returns the scoped results" do
        $team_policy_value = true
        visit "/admin/resources/teams/#{team.id}/team_members?turbo_frame=has_many_field_show_team_members"
        puts page.body.inspect
        sleep 15
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
