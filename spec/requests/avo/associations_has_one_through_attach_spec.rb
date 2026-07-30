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
end
