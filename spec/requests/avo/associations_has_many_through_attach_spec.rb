# frozen_string_literal: true

require "rails_helper"

# The collection counterpart of `associations_has_one_through_attach_spec.rb`.
# `attach_fields` builds the join record itself, so it has to build it through
# the association — otherwise the association's scope never gets stamped and the
# attach writes a row the association doesn't match.
RSpec.describe "Associations attach has_many through", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let(:team) { create :team }
  let(:user) { create :user }

  before do
    login_as admin_user, scope: :user
  end

  def attach(association, fields)
    post "/admin/resources/teams/#{team.id}/#{association}", params: {fields:, view: "show"}, as: :turbo_stream
  end

  context "when the through association is scoped" do
    it "applies the scope when attach_fields are present" do
      expect {
        attach :admins, {related_id: user.id, notes: "via attach_fields"}
      }.to change { TeamMembership.where(team: team).count }.by(1)

      expect(team.reload.admins).to eq([user])
      expect(team.admin_memberships.first.level).to eq("admin")
      expect(team.admin_memberships.first.notes).to eq("via attach_fields")
    end

    it "applies the scope without attach_fields too" do
      attach :admins, {related_id: user.id}

      expect(team.reload.admins).to eq([user])
      expect(team.admin_memberships.first.level).to eq("admin")
    end
  end

  # `Store#patrons` goes through the unscoped `patronships`, and is the path
  # `spec/system/avo/group_2/attach_with_additional_fields_spec.rb` covers.
  context "when the through association is unscoped" do
    let(:store) { create :store }

    it "still writes the attach fields onto the join record" do
      expect {
        post "/admin/resources/stores/#{store.id}/patrons",
          params: {fields: {related_id: user.id, review: "Great paper towels"}, view: "show"},
          as: :turbo_stream
      }.to change(StorePatron, :count).by(1)

      expect(store.reload.patrons).to eq([user])
      expect(StorePatron.find_by(store: store, user: user).review).to eq("Great paper towels")
    end
  end

  context "with a belongs_to attach field" do
    let(:store) { create :store }
    let(:referrer) { create :user }

    before do
      Avo::Resources::Store.with_temporary_items do
        field :patrons, as: :has_many, through: :patronships, attach_fields: -> {
          field :review, as: :text
          field :referrer, as: :belongs_to
        }
      end
    end

    after { Avo::Resources::Store.restore_items_from_backup }

    def attach_patron(referrer_id)
      post "/admin/resources/stores/#{store.id}/patrons",
        params: {fields: {related_id: user.id, review: "Great paper towels", referrer_id:}, view: "show"},
        as: :turbo_stream
    end

    it "renders the field's foreign key and writes it onto the join record" do
      get "/admin/resources/stores/#{store.id}/patrons/new"
      expect(Capybara.string(response.body)).to have_select("fields[referrer_id]")

      attach_patron(referrer.to_param)

      expect(StorePatron.find_by(store:, user:)).to have_attributes(review: "Great paper towels", referrer:)
    end

    it "fails the attach on the field when the value matches no record" do
      expect { attach_patron("no-such-user") }.not_to change(StorePatron, :count)

      expect(flash[:error]).to eq("Failed to attach User")
      expect(response.body).to include("Referrer is invalid")
    end
  end
end
