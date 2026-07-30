# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Associations attach has_one through", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let(:team) { create :team }
  let(:user) { create :user, first_name: "Admin", last_name: "Candidate" }

  before do
    login_as admin_user, scope: :user
  end

  it "attaches a record through a has_one :through association" do
    expect {
      post "/admin/resources/teams/#{team.id}/admin",
        params: {
          fields: {related_id: user.id},
          view: "show"
        },
        as: :turbo_stream
    }.to change { team.reload.admin }.from(nil).to(user)

    expect(team.admin_membership.level).to eq("admin")
  end

  context "with attach_fields" do
    it "goes through the association so the scope still applies" do
      expect {
        post "/admin/resources/teams/#{team.id}/admin",
          params: {
            fields: {related_id: user.id, notes: "Promoted by Bob"},
            view: "show"
          },
          as: :turbo_stream
      }.to change { team.reload.admin }.from(nil).to(user)

      expect(team.admin_membership.level).to eq("admin")
      expect(team.admin_membership.notes).to eq("Promoted by Bob")
    end

    it "replaces the existing join record instead of adding a second one" do
      team.update!(admin: user)
      other_user = create :user

      expect {
        post "/admin/resources/teams/#{team.id}/admin",
          params: {
            fields: {related_id: other_user.id, notes: "Handover"},
            view: "show"
          },
          as: :turbo_stream
      }.not_to change { TeamMembership.where(team: team).count }

      expect(team.reload.admin).to eq(other_user)
      expect(team.admin_membership.notes).to eq("Handover")
    end
  end
end
