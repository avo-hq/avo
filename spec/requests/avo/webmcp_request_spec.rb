require "rails_helper"

# Server half of WebMCP support: the resource form announces itself to the browser's agent through the
# declarative attributes (Avo::Concerns::FormBuilder), and the layout declares the search tool for the
# webmcp-tool controller (ApplicationHelper#webmcp_search_tool). The browser side is
# spec/system/avo/group_2/webmcp_spec.rb.
RSpec.describe "WebMCP", type: :request do
  let(:admin_user) { create :user, roles: {admin: true}, first_name: "Adrian", last_name: "Marin" }

  before { login_as admin_user }

  after { Avo.configuration.webmcp = {} }

  it "is enabled by default" do
    expect(Avo::Configuration.new.webmcp).to eq(enabled: true)
  end

  it "announces the edit form as an update tool named after the resource" do
    get "/admin/resources/users/#{admin_user.to_param}/edit"

    form = Nokogiri::HTML(response.body).at_css("form[toolname]")
    expect(form["toolname"]).to eq "update_user"
    expect(form["tooldescription"]).to include 'Update the User "Adrian Marin"'
    expect(form["data-controller"]).to include "webmcp-form"
    # The agent fills, the person saves: never auto-submitted.
    expect(form["toolautosubmit"]).to be_nil
  end

  it "announces the new form as a create tool" do
    get "/admin/resources/users/new"

    form = Nokogiri::HTML(response.body).at_css("form[toolname]")
    expect(form["toolname"]).to eq "create_user"
    expect(form["tooldescription"]).to eq "Create a new User."
  end

  it "declares the search tool over the resources the viewer can search" do
    get "/admin/resources/users"

    element = Nokogiri::HTML(response.body).at_css("[data-controller='webmcp-tool']")
    expect(element["data-webmcp-tool-url-value"]).to eq "/admin/avo_api/{resource}/search"

    tool = JSON.parse(element["data-webmcp-tool-definition-value"])
    expect(tool["name"]).to eq "search_records"
    expect(tool["annotations"]).to eq("readOnlyHint" => true, "untrustedContentHint" => true)
    resources = tool.dig("inputSchema", "properties", "resource", "enum")
    expect(resources).to include "users"
    # No search query, no entry: the tool only lists what the search endpoint would answer.
    expect(resources).not_to include "events"
  end

  it "tells the browser the setting" do
    get "/admin/resources/users"

    expect(response.body).to include("Avo.configuration.webmcp = {\n    enabled: true")
  end

  context "when disabled" do
    before { Avo.configuration.webmcp = {enabled: false} }

    it "announces nothing" do
      get "/admin/resources/users/#{admin_user.to_param}/edit"

      expect(response.body).not_to include("toolname=")
      expect(response.body).not_to include("webmcp-form")
      expect(response.body).not_to include("webmcp-tool")
      expect(response.body).to include("Avo.configuration.webmcp = {\n    enabled: false")
    end
  end
end
