# frozen_string_literal: true

require "rails_helper"

# The collection counterpart of `associations_has_one_through_detach_spec.rb`.
# `has_many :through` and `has_one :through` share the problem: when a pair of
# records is linked more than once, only the association's scope says which join
# row belongs to the association.
RSpec.describe "Associations detach has_many through", type: :request do
  include_context "with a destroyable join record"

  let(:admin_user) { create :user, roles: {admin: true} }
  let(:team) { create :team }
  let(:user) { create :user }

  before do
    login_as admin_user, scope: :user
  end

  def detach(association, record = user)
    delete "/admin/resources/teams/#{team.id}/#{association}/#{record.id}", as: :turbo_stream
  end

  it "destroys the join record the association scope points at" do
    member_row = TeamMembership.create!(team: team, user: user, level: "member")
    admin_row = TeamMembership.create!(team: team, user: user, level: "admin")

    expect(team.admins).to eq([user])

    without_destroy_callback { detach :admins }

    expect(TeamMembership.exists?(admin_row.id)).to be false
    expect(TeamMembership.exists?(member_row.id)).to be true
    expect(team.reload.admins).to be_empty
  end

  it "leaves join records outside the association's scope alone" do
    member_row = TeamMembership.create!(team: team, user: user, level: "member")

    expect { detach :admins }.not_to change(TeamMembership, :count)

    expect(TeamMembership.exists?(member_row.id)).to be true
  end

  # The unscoped through association still detaches the way it always has.
  it "detaches through an unscoped through association" do
    membership = TeamMembership.create!(team: team, user: user, level: "member")

    without_destroy_callback { detach :team_members }

    expect(TeamMembership.exists?(membership.id)).to be false
  end
end
