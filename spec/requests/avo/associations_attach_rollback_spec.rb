# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Associations attach rollback", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let(:team) { create :team }
  let(:alpha) { create :user, first_name: "Alpha", last_name: "One" }
  let(:beta) { create :user, first_name: "Beta", last_name: "Two" }

  before do
    login_as admin_user, scope: :user
  end

  it "rolls back earlier attachments when a later attach fails" do
    call_count = 0

    allow_any_instance_of(Avo::AssociationsController).to receive(:attach_record).and_wrap_original do |method, *args|
      call_count += 1

      if call_count == 2
        raise ActiveRecord::RecordInvalid.new(
          TeamMembership.new.tap { |record| record.errors.add(:base, "forced failure") }
        )
      end

      method.call(*args)
    end

    expect {
      post "/admin/resources/teams/#{team.id}/team_members",
        params: {
          fields: {related_id: [alpha.id, beta.id]},
          view: "show"
        },
        as: :turbo_stream
    }.not_to change { team.reload.team_members.count }

    expect(team.team_members).not_to include alpha, beta
  end
end
