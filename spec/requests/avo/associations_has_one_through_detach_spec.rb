# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Associations detach has_one through", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let(:team) { create :team }
  let(:user) { create :user }

  before do
    login_as admin_user, scope: :user
  end

  # The dummy's `raise_test_error` before_destroy exists to prove other specs go
  # through `destroy`. Most of the specs here need the destroy to actually land
  # so we can tell which row Avo picked.
  def without_destroy_callback
    TeamMembership.skip_callback(:destroy, :before, :raise_test_error, raise: false)
    yield
  ensure
    TeamMembership.set_callback(:destroy, :before, :raise_test_error, if: -> { Rails.env.test? })
  end

  def detach(record = user)
    delete "/admin/resources/teams/#{team.id}/admin/#{record.id}", as: :turbo_stream
  end

  it "does not blow up when there is no join record to detach" do
    expect { detach }.not_to change(TeamMembership, :count)

    expect(response).to have_http_status(:found)
  end

  it "leaves join records that don't match the association scope alone" do
    membership = TeamMembership.create!(team: team, user: user, level: "member")

    detach

    expect(TeamMembership.exists?(membership.id)).to be true
  end

  context "when the same user has both a scoped and an unscoped join record" do
    it "destroys the join record the association scope points at" do
      member_row = TeamMembership.create!(team: team, user: user, level: "member")
      admin_row = TeamMembership.create!(team: team, user: user, level: "admin")

      expect(team.reload.admin).to eq(user)

      without_destroy_callback { detach }

      expect(TeamMembership.exists?(admin_row.id)).to be false
      expect(TeamMembership.exists?(member_row.id)).to be true
      expect(team.reload.admin).to be_nil
    end
  end

  # Assigning `nil` detaches whatever is currently attached, ignoring the record
  # named in the URL. For a singular through that would destroy the current join
  # row — reachable from a stale page or a double detach.
  it "leaves the association alone when the URL names a record that isn't attached" do
    admin_row = TeamMembership.create!(team: team, user: user, level: "admin")
    stranger = create :user

    expect(team.reload.admin).to eq(user)

    without_destroy_callback { detach stranger }

    expect(TeamMembership.exists?(admin_row.id)).to be true
    expect(team.reload.admin).to eq(user)
  end

  # Rails' `= nil` destroys the join record with `destroy`, which returns false
  # when a callback aborts — the detach would report success with the row still
  # there. `has_many :through` already detaches with `destroy!`; a singular
  # through now does the same.
  it "surfaces a blocked destroy instead of reporting success" do
    admin_row = TeamMembership.create!(team: team, user: user, level: "admin")
    ENV["MEMBERSHIP_ABORT_DESTROY"] = "true"

    without_destroy_callback do
      expect { detach }.to raise_error(ActiveRecord::RecordNotDestroyed)
    end

    expect(TeamMembership.exists?(admin_row.id)).to be true
  ensure
    ENV.delete("MEMBERSHIP_ABORT_DESTROY")
  end
end
