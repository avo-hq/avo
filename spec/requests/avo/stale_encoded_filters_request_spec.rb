# frozen_string_literal: true

require "rails_helper"

# Filter state lives in the URL and (with session persistence on) in the session,
# so it outlives the code that produced it. A filter that has since been removed
# from `def filters` must not take the whole index down.
RSpec.describe "Stale encoded filters", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  # The Team resource defaults `Avo::Filters::MembersFilter` to members-only,
  # so both teams need a member to show up on the index at all.
  let!(:alpha_team) { create :team, name: "Alpha Team" }
  let!(:beta_team) { create :team, name: "Beta Team" }

  before do
    alpha_team.team_members << admin_user
    beta_team.team_members << admin_user

    login_as admin_user
  end

  def encode(filters)
    Avo::Filters::BaseFilter.encode_filters(filters)
  end

  it "discards a filter class that is no longer listed in `def filters`" do
    get "/admin/resources/teams", params: {encoded_filters: encode("Avo::Filters::PublishedFilter" => true)}

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Alpha Team", "Beta Team")
  end

  it "discards a filter class that no longer exists" do
    get "/admin/resources/teams", params: {encoded_filters: encode("Avo::Filters::Tickets::ByCity" => "Berlin")}

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Alpha Team", "Beta Team")
  end

  it "keeps applying the filters the resource does declare" do
    get "/admin/resources/teams", params: {encoded_filters: encode("Avo::Filters::NameFilter" => "Alpha")}

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Alpha Team")
    expect(response.body).not_to include("Beta Team")
  end

  it "keeps applying declared filters alongside a stale one" do
    get "/admin/resources/teams", params: {
      encoded_filters: encode(
        "Avo::Filters::Tickets::ByCity" => "Berlin",
        "Avo::Filters::NameFilter" => "Alpha"
      )
    }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Alpha Team")
    expect(response.body).not_to include("Beta Team")
  end
end
