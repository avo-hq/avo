# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Associations detach has_one through", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let(:team) { create :team }
  let(:user) { create :user }

  before do
    login_as admin_user, scope: :user
  end

  def detach
    delete "/admin/resources/teams/#{team.id}/admin/#{user.id}", as: :turbo_stream
  end

  it "does not blow up when there is no join record to detach" do
    expect { detach }.not_to change(TeamMembership, :count)

    expect(response).to have_http_status(:ok).or have_http_status(:found)
  end

  it "leaves join records that don't match the association scope alone" do
    membership = TeamMembership.create!(team: team, user: user, level: "member")

    detach

    expect(TeamMembership.exists?(membership.id)).to be true
  end

  context "when the same user has both a scoped and an unscoped join record" do
    # The dummy's `raise_test_error` before_destroy exists to prove other specs
    # go through `destroy`. Here we need the destroy to actually land so we can
    # tell which row Avo picked.
    around do |example|
      TeamMembership.skip_callback(:destroy, :before, :raise_test_error, raise: false)
      example.run
      TeamMembership.set_callback(:destroy, :before, :raise_test_error, if: -> { Rails.env.test? })
    end

    it "destroys the join record the association scope points at" do
      member_row = TeamMembership.create!(team: team, user: user, level: "member")
      admin_row = TeamMembership.create!(team: team, user: user, level: "admin")

      expect(team.reload.admin).to eq(user)

      detach

      expect(TeamMembership.exists?(admin_row.id)).to be false
      expect(TeamMembership.exists?(member_row.id)).to be true
      expect(team.reload.admin).to be_nil
    end
  end
end
