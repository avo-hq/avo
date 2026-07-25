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

# Unit 5: the server-rendered half of the handle. What matters here is what a
# browser with no JS receives — the system specs cover everything after the
# controller connects.
RSpec.describe "Sidebar resize handle", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before { login_as admin_user }

  let(:path) { "/admin/failed_to_load" }

  def handle
    Nokogiri::HTML(response.body).at_css(".sidebar-resize-handle")
  end

  # R20 / the no-JS contract. The partial always renders `hidden`;
  # sidebar_resize_controller is the only thing that removes it. Without JS the
  # element stays inert: no orphaned tab stop, no strip eating content clicks.
  it "always renders the handle hidden, whatever the sidebar state" do
    get path

    expect(handle).to be_present
    expect(handle.attributes).to have_key("hidden")
  end

  # R21's static half. axe-core 4.12 lists aria-valuenow as a REQUIRED attribute
  # of role="separator", so these cannot wait for Unit 8 to make them dynamic.
  it "renders a labelled separator with the server-computed value and bounds" do
    cookies["avo.sidebar.width"] = "384"
    get path

    expect(handle["role"]).to eq("separator")
    expect(handle["tabindex"]).to eq("0")
    expect(handle["aria-orientation"]).to eq("vertical")
    expect(handle["aria-controls"]).to eq("main-sidebar")
    expect(handle["aria-label"]).to be_present
    expect(handle["title"]).to be_present
    expect(handle["aria-valuenow"]).to eq("384")
    expect(handle["aria-valuemin"]).to eq("200")
    expect(handle["aria-valuemax"]).to eq("480")
  end

  it "falls back to the 256px default value with no stored width" do
    get path

    expect(handle["aria-valuenow"]).to eq("256")
  end

  # aria-controls has to resolve, or the separator points at nothing.
  it "points aria-controls at an element that exists" do
    get path

    expect(Nokogiri::HTML(response.body).at_css("##{handle["aria-controls"]}")).to be_present
  end

  # The S5 off-switch: drag-only resizing is a known WCAG SC 2.5.7 gap, so a host
  # under an AA/VPAT obligation can remove the affordance entirely rather than
  # inherit a failure by upgrading.
  context "with Avo.configuration.sidebar_resizable = false" do
    around do |example|
      Avo.configuration.sidebar_resizable = false
      example.run
      Avo.configuration.sidebar_resizable = true
    end

    it "renders no handle at all" do
      get path

      expect(handle).to be_nil
    end
  end
end

# Avo.configuration.sidebar_default_width — the host-facing knob for where the
# sidebar starts before anyone drags it. The bounds around it stay unconfigurable
# by design; this is the only width knob.
RSpec.describe "Sidebar default width configuration", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before { login_as admin_user }

  let(:path) { "/admin/failed_to_load" }

  def with_default_width(value)
    original = Avo.configuration.sidebar_default_width
    Avo.configuration.sidebar_default_width = value
    yield
  ensure
    Avo.configuration.sidebar_default_width = original
  end

  def carrier_script
    Nokogiri::HTML(response.body).css("script").find { |node| node.text.include?("--sidebar-width") }
  end

  def handle
    Nokogiri::HTML(response.body).at_css(".sidebar-resize-handle")
  end

  describe "clamping" do
    it "accepts a value inside the bounds" do
      with_default_width(400) { expect(Avo.configuration.sidebar_default_width).to eq(400) }
    end

    # Outside the bounds the sidebar would start at a width the handle cannot
    # drag back to, and aria-valuenow would sit outside its own min/max.
    it "clamps above the maximum and below the minimum" do
      with_default_width(9999) { expect(Avo.configuration.sidebar_default_width).to eq(480) }
      with_default_width(10) { expect(Avo.configuration.sidebar_default_width).to eq(200) }
    end

    it "accepts a numeric string" do
      with_default_width("400") { expect(Avo.configuration.sidebar_default_width).to eq(400) }
    end

    # A typo must not silently ship a 200px sidebar, which is what clamping an
    # unparseable value would do.
    it "falls back to 256 rather than the minimum for an unusable value" do
      with_default_width("wide") { expect(Avo.configuration.sidebar_default_width).to eq(256) }
      with_default_width(nil) { expect(Avo.configuration.sidebar_default_width).to eq(256) }
    end
  end

  describe "rendering" do
    # Zero bytes and zero CSP surface for the overwhelming majority who never
    # touch this — same discipline as "no cookie means no script".
    it "emits nothing when the default is unchanged" do
      get path

      expect(response.body).not_to include("--sidebar-width-default")
      expect(carrier_script).to be_nil
    end

    it "emits the configured default through the pre-paint carrier" do
      with_default_width(400) { get path }

      expect(carrier_script.text).to include("setProperty('--sidebar-width-default', 400 + 'px')")
      expect(carrier_script.attributes).to have_key("nonce")
      expect(Nokogiri::HTML(response.body).at_css("html")["style"]).to be_nil
    end

    it "exposes the configured default to the JS layer" do
      with_default_width(400) { get path }

      expect(response.body).to match(/widthDefault:\s*400/)
    end

    it "uses the configured default for the handle's static aria-valuenow" do
      with_default_width(400) { get path }

      expect(handle["aria-valuenow"]).to eq("400")
    end

    # A dragged width is a per-user preference and outranks the install-wide
    # starting width. Both land on <html>; the CSS fallback chain does the rest.
    it "lets a stored cookie width outrank the configured default" do
      with_default_width(400) do
        cookies["avo.sidebar.width"] = "300"
        get path
      end

      expect(carrier_script.text).to include("setProperty('--sidebar-width-default', 400 + 'px')")
      expect(carrier_script.text).to include("setProperty('--sidebar-width-stored', 300 + 'px')")
      expect(handle["aria-valuenow"]).to eq("300")
    end
  end
end
