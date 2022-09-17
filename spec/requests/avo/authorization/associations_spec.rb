require "rails_helper"

RSpec.describe "Avo::TeamsController", type: :feature do
  let!(:team) { create :team }
  let!(:user) { create :user }
  let!(:post) { create :post, user: user }
  let!(:team_member) { team.team_members << user }

  describe "all false" do
    context ".index" do
      it "redirects to the root_path" do
        allow_any_instance_of(TeamPolicy).to receive(:view_team_members?).and_return false

        visit "/admin/resources/teams/#{team.id}/team_members?turbo_frame=has_many_field_show_team_members"

        expect(current_path).to eql avo_home_path
      end

      it "does not render the field on the parent resource" do
        allow_any_instance_of(TeamPolicy).to receive(:view_team_members?).and_return false

        visit "/admin/resources/teams/#{team.id}"

        expect(page).not_to have_text "Loading team members"
        expect(page).not_to have_selector "turbo-frame#has_many_field_show_team_members"
      end

      it "renders the field on the parent resource" do
        allow_any_instance_of(TeamPolicy).to receive(:view_team_members?).and_return true

        visit "/admin/resources/teams/#{team.id}"

        expect(page).to have_text "Loading team members"
        expect(page).to have_selector "turbo-frame#has_many_field_show_team_members"
      end
    end

    describe "detach has_one" do
      subject do
        visit "/admin/resources/users/#{user.slug}/post/#{post.id}?turbo_frame=has_one_field_show_post"
        page
      end

      describe "when disabled" do
        before do
          allow_any_instance_of(UserPolicy).to receive(:detach_post?).and_return false
        end

        it { is_expected.not_to have_text "Detach main post" }
      end

      describe "when enabled" do
        before do
          allow_any_instance_of(UserPolicy).to receive(:detach_post?).and_return true
        end

        it { is_expected.to have_text "Detach main post" }
      end
    end

    describe "attach has_one" do
      let(:second_user) { create :user }

      subject do
        visit "/admin/resources/users/#{second_user.slug}"
        page
      end

      describe "when disabled" do
        before do
          allow_any_instance_of(UserPolicy).to receive(:attach_post?).and_return false
        end

        it { is_expected.not_to have_text "Attach main post" }
      end

      describe "when enabled" do
        before do
          allow_any_instance_of(UserPolicy).to receive(:attach_post?).and_return true
        end

        it { is_expected.to have_text "Attach main post" }
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

  describe "all true" do
    context ".index" do
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
