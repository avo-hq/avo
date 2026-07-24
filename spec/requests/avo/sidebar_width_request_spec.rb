require "rails_helper"

# Unit 2 of the resizable-sidebar feature: the server-rendered half of the
# pre-paint width carrier. These assertions look at the RAW server HTML
# (response.body), which is exactly what the CSP argument is about — the width
# must arrive via a nonce'd <script> doing a CSSOM write, never via an inline
# `style` attribute that would make every admin page depend on
# style-src 'unsafe-inline'. A system spec cannot check this: once the carrier
# runs, element.style.setProperty puts an inline style on <html> in the live
# DOM. No browser is needed here.
#
# CSP is off in the dummy unless DUMMY_CSP_REPORT_ONLY=1 (boot-gated), so
# content_security_policy_nonce is nil and the rendered nonce attribute is
# present-but-empty. We assert the nonce mechanism is wired (attribute present);
# the value-bearing check is the documented DUMMY_CSP_REPORT_ONLY=1 run.
RSpec.describe "Sidebar width carrier", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before { login_as admin_user }

  # Renders the full avo/application layout (head + body chrome), same page the
  # overrides stylesheet/JS request specs use.
  let(:path) { "/admin/failed_to_load" }

  def document
    Nokogiri::HTML(response.body)
  end

  def carrier_script
    document.css("script").find { |node| node.text.include?("--sidebar-width-stored") }
  end

  context "with a valid width cookie" do
    before do
      cookies["avo.sidebar.width"] = "384"
      get path
    end

    it "renders 200 and emits the carrier script writing the validated width" do
      expect(response).to have_http_status(:ok)

      script = carrier_script
      expect(script).to be_present
      # A bare number literal (384), not a quoted cookie string — the type
      # invariant made visible in the emitted JS.
      expect(script.text).to include("setProperty('--sidebar-width-stored', 384 + 'px')")
    end

    it "delivers the width via a nonce'd <script>, not an inline style attribute" do
      # The nonce mechanism is wired (real value only under DUMMY_CSP_REPORT_ONLY=1).
      expect(carrier_script.attributes).to have_key("nonce")

      # The whole point of the carrier: no inline style attribute on <html>, so
      # no page depends on style-src 'unsafe-inline'.
      expect(document.at_css("html")["style"]).to be_nil
      expect(response.body).not_to match(/<html[^>]*\sstyle=/)
    end
  end

  context "with no width cookie (R9)" do
    before { get path }

    it "renders 200 and emits no carrier script" do
      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("--sidebar-width-stored")
      expect(carrier_script).to be_nil
    end
  end

  # The 500-prevention case end-to-end. `%C3%28` decodes to the bytes \xC3\x28,
  # which Rack hands back as a UTF-8-tagged String with invalid bytes. Set via a
  # raw Cookie header so the exact threat-model input reaches the parser; the
  # page must render 200, not raise.
  context "with an invalid-UTF-8 width cookie" do
    it "renders 200 (no 500) and emits no carrier script" do
      get path, headers: {"Cookie" => "avo.sidebar.width=%C3%28"}

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("--sidebar-width-stored")
    end
  end

  # An over-max value still renders (clamped for display by the client/CSS); the
  # carrier writes the raw validated Integer and the CSS clamp() caps it.
  context "with an over-max width cookie" do
    before do
      cookies["avo.sidebar.width"] = "9999"
      get path
    end

    it "clamps to the maximum before emitting" do
      expect(response).to have_http_status(:ok)
      expect(carrier_script.text).to include("setProperty('--sidebar-width-stored', 480 + 'px')")
    end
  end

  describe "window.Avo.configuration bounds" do
    before { get path }

    it "exposes the sidebar width bounds for the JS layer" do
      expect(response.body).to match(/widthMin:\s*200/)
      expect(response.body).to match(/widthMax:\s*480/)
    end
  end
end
