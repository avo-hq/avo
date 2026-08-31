require "rails_helper"

# Server half of WebMCP support: the layout declares the search tool for the webmcp-tool controller
# (ApplicationHelper#webmcp_search_tool). Core announces no write tools — those are avo-mcp_server's,
# registered from the gem. The browser side is spec/system/avo/group_2/webmcp_spec.rb.
RSpec.describe "WebMCP", type: :request do
  let(:admin_user) { create :user, roles: {admin: true}, first_name: "Adrian", last_name: "Marin" }

  before { login_as admin_user }

  after { Avo.configuration.webmcp = {} }

  it "is enabled by default" do
    expect(Avo::Configuration.new.webmcp).to eq(enabled: true)
  end

  it "declares the search tool without enumerating the panel's resources" do
    get "/admin/resources/users"

    element = Nokogiri::HTML(response.body).at_css("[data-controller='webmcp-tool']")
    expect(element["data-webmcp-tool-url-value"]).to eq "/admin/avo_api/{resource}/search"

    tool = JSON.parse(element["data-webmcp-tool-definition-value"])
    expect(tool["name"]).to eq "search_records"
    expect(tool["annotations"]).to eq("readOnlyHint" => true, "untrustedContentHint" => true)
    # No enum: the roster would grow with the panel. `list_resources` is where a name comes from and
    # the endpoint refuses anything else.
    expect(tool.dig("inputSchema", "properties", "resource")).not_to have_key "enum"
  end

  it "tells the browser the setting" do
    get "/admin/resources/users"

    expect(response.body).to include("Avo.configuration.webmcp = {\n    enabled: true")
  end

  context "when disabled" do
    before { Avo.configuration.webmcp = {enabled: false} }

    it "announces nothing" do
      get "/admin/resources/users"

      expect(response.body).not_to include("webmcp-tool")
      expect(response.body).to include("Avo.configuration.webmcp = {\n    enabled: false")
    end
  end
end
