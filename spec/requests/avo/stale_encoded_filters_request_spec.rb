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

  describe "a value that doesn't decode to filters" do
    [
      ["isn't JSON", "not-base64"],
      ["is truncated JSON", Base64.encode64('{"Avo::Filters::NameFilter"')],
      ["is JSON but not an object", Base64.encode64("[1]")],
      ["isn't valid UTF-8", Base64.encode64("\xFF\xFE")]
    ].each do |description, value|
      it "ignores one that #{description}" do
        get "/admin/resources/teams", params: {encoded_filters: value}

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Alpha Team", "Beta Team")
      end
    end

    it "ignores one that arrives as a list" do
      get "/admin/resources/teams", params: {encoded_filters: ["not-base64"]}

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Alpha Team", "Beta Team")
    end

    context "with session persistence" do
      around do |example|
        Avo.configuration.persistence = {driver: :session}
        example.run
        Avo.configuration.persistence = {driver: nil}
      end

      it "doesn't break later visits once it's remembered" do
        get "/admin/resources/teams", params: {encoded_filters: "not-base64"}
        expect(response).to have_http_status(:ok)

        get "/admin/resources/teams"
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Alpha Team", "Beta Team")
      end
    end
  end
end
