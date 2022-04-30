require "rails_helper"

RSpec.feature Avo::SearchController, type: :controller do
  let!(:user) { create :user }
  let!(:admin) { create :user, roles: {admin: true} }
  let!(:team) { create :team, name: "Ruby" }
  let!(:java_team) { create :team, name: "Java" }
  let!(:review) { create :review, id: 1, user: user, reviewable: team }

  it "returns only the admins" do
    get :show, params: {
      resource_name: "users",
      via_association_id: "user",
      via_reflection_class: "Review",
      via_reflection_id: 1
    }

    expect(json["users"]["results"].count).to eq 1
    expect(json["users"]["results"].first["_id"]).to eq admin.id
  end

  it "returns only the ones requested in the query" do
    get :show, params: {
      resource_name: "teams",
      via_association_id: "reviewable",
      via_reflection_class: "Review",
      via_reflection_id: 1,
      like: "ru"
    }

    expect(json["teams"]["results"].count).to eq 1
    expect(json["teams"]["results"].first["_id"]).to eq team.id
    expect(json["teams"]["results"].first["_label"]).to eq 'Ruby'
  end
end
