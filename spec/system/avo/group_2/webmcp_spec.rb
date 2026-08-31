require "rails_helper"

# Browser half of WebMCP support. WebMCP is Chrome-only and behind a flag, so the browser running this
# suite has no document.modelContext: the spec installs a fake that records registrations and honours the
# abort signal, then drives the app through Turbo — the fake survives a Turbo visit, and a page's tools
# living exactly as long as the page is the thing being proven.
#
# Core registers one tool. A form carries no tool attributes: writes are avo-mcp_server's, and the edit
# page is visited here only to prove the search tool is dropped and re-registered across a Turbo swap.
RSpec.describe "WebMCP", type: :system do
  let!(:user) { create :user, first_name: "Adrian", last_name: "Marin" }

  before do
    visit "/admin/resources/users"

    page.execute_script(<<~JS)
      window.webmcpLog = { registered: [], aborted: [], tools: {} }
      Object.defineProperty(document, "modelContext", {
        configurable: true,
        value: {
          registerTool(definition, { signal } = {}) {
            window.webmcpLog.registered.push(definition.name)
            window.webmcpLog.tools[definition.name] = definition
            signal?.addEventListener("abort", () => window.webmcpLog.aborted.push(definition.name))
            return Promise.resolve()
          }
        }
      })
    JS
  end

  def log
    page.evaluate_script("window.webmcpLog")
  end

  it "registers the search tool per page, drops it with the page, and answers it from the search endpoint" do
    # The fake went in after this page's controller connected, so the first registration comes with the
    # next Turbo visit.
    find("a[href='/admin/resources/users/#{user.to_param}']", match: :first).click
    expect(page).to have_text "Adrian Marin"
    expect(log["registered"]).to eq ["search_records"]
    expect(log["aborted"]).to eq []

    find("a[href*='/admin/resources/users/#{user.to_param}/edit']", match: :first).click
    expect(page).to have_field "user[first_name]"
    expect(log["aborted"]).to eq ["search_records"]
    expect(log["registered"]).to eq ["search_records", "search_records"]

    result = page.evaluate_async_script(<<~JS)
      const done = arguments[0]
      window.webmcpLog.tools.search_records
        .execute({ resource: "users", q: "Adrian" }, {})
        .then(done, (error) => done(`failed: ${error.message}`))
    JS
    expect(result["content"].first["type"]).to eq "text"
    payload = JSON.parse(result["content"].first["text"])
    expect(payload.dig("users", "results").first["_url"]).to eq "/admin/resources/users/#{user.to_param}"
  end
end
