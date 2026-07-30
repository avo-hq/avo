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

  # Rails writes a singular through's join record with `create`, which returns
  # an unsaved record instead of raising when it's invalid — so nothing but an
  # explicit save catches this.
  context "when the join record is invalid" do
    around do |example|
      ENV["MEMBERSHIP_FAIL"] = "true"
      example.run
    ensure
      ENV.delete("MEMBERSHIP_FAIL")
    end

    it "reports the failure instead of a phantom success" do
      expect {
        post "/admin/resources/teams/#{team.id}/admin",
          params: {fields: {related_id: user.id}, view: "show"},
          as: :turbo_stream
      }.not_to change(TeamMembership, :count)

      expect(team.reload.admin).to be_nil
      expect(flash[:notice]).to be_nil
      expect(flash[:error]).to eq("Failed to attach User")
    end

    it "reports the failure when attach_fields are present too" do
      expect {
        post "/admin/resources/teams/#{team.id}/admin",
          params: {fields: {related_id: user.id, notes: "Promoted by Bob"}, view: "show"},
          as: :turbo_stream
      }.not_to change(TeamMembership, :count)

      expect(team.reload.admin).to be_nil
      expect(flash[:error]).to eq("Failed to attach User")
    end
  end
end
