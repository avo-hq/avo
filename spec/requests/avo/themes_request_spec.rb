require "rails_helper"

# The active theme is resolved per request from lock, pick, config, and the
# offered list, and it decides the <html> class, the linked stylesheets, the
# view path, and the brand assets. Fixtures: the dummy app's local theme
# Lagoon (views + logo + chart colors) and the gem-shaped Harbor theme
# (vendor/avo-harbor_theme, views + accent lock).
RSpec.describe "Themes", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let(:appearance) { Avo.configuration.appearance }

  before do
    login_as admin_user
    # The dummy app persists picks to the database; the cookie path is what
    # most apps run, so it is the default here and one example opts back in.
    allow(appearance).to receive(:database_persistence?).and_return(false)
  end

  def html_classes
    response.body[/<html[^>]*class="([^"]*)"/, 1].to_s.split
  end

  describe "resolution" do
    it "lands on Paper with no pick and no configuration" do
      get "/admin/resources/users"

      expect(html_classes).to include("avo-theme-paper")
    end

    it "honors the avo.theme cookie when it names an offered theme" do
      cookies["avo.theme"] = "dracula"
      get "/admin/resources/users"

      expect(html_classes).to include("avo-theme-dracula")
      expect(html_classes).not_to include("avo-theme-paper")
    end

    it "ignores a cookie naming an unknown or malformed theme" do
      cookies["avo.theme"] = "nope"
      get "/admin/resources/users"
      expect(html_classes).to include("avo-theme-paper")

      cookies["avo.theme"] = "dracula<script>"
      get "/admin/resources/users"
      expect(html_classes).to include("avo-theme-paper")
    end

    it "ignores a cookie naming a theme that is installed but not offered" do
      allow(appearance).to receive(:themes).and_return([:paper, :coastal])
      cookies["avo.theme"] = "dracula"
      get "/admin/resources/users"

      expect(html_classes).to include("avo-theme-paper")
    end

    it "uses the configured default theme when nothing is picked" do
      allow(appearance).to receive(:theme).and_return(:nord)
      get "/admin/resources/users"

      expect(html_classes).to include("avo-theme-nord")
    end

    it "pins the configured theme when :theme is locked, ignoring the cookie" do
      allow(appearance).to receive(:theme).and_return(:nord)
      allow(appearance).to receive(:theme_locked?).and_return(true)
      cookies["avo.theme"] = "dracula"
      get "/admin/resources/users"

      expect(html_classes).to include("avo-theme-nord")
      expect(response.body).not_to include('data-appearance-theme="dracula"')
    end

    it "reads the pick from the database settings when persistence is :database" do
      allow(appearance).to receive_messages(database_persistence?: true, load_settings_block: -> { {theme: "monokai"} })
      get "/admin/resources/users"

      expect(html_classes).to include("avo-theme-monokai")
    end
  end

  describe "head" do
    it "links the built-in stylesheet and each installed theme after the brand override and before avo-overrides" do
      get "/admin/resources/users"

      head = response.body[%r{<head>.*</head>}m]
      built_ins = head.index("avo/themes")
      harbor = head.index("avo/themes/harbor")
      lagoon = head.index("avo/themes/lagoon")
      overrides = head.index("avo-overrides")
      application = head.index("avo/application")

      expect([application, built_ins, harbor, lagoon, overrides]).to all(be_present)
      expect(application).to be < built_ins
      expect(built_ins).to be < harbor
      expect(harbor).to be < lagoon
      expect(lagoon).to be < overrides
    end

    it "exposes the theme dimension to the JS bridge" do
      cookies["avo.theme"] = "lagoon"
      get "/admin/resources/users"

      expect(response.body).to include("theme: 'lagoon'")
      expect(response.body).to include("themeLocked: false")
      expect(response.body).to match(/themes: \[.*"paper".*"lagoon".*\]/)
      expect(response.body).to match(/themesNeedingVisit: \[.*"harbor".*"lagoon".*\]/)
    end
  end

  describe "picker" do
    it "lists every offered theme with a tile in the picker" do
      get "/admin/resources/users"

      Avo.theme_manager.offered.each do |theme|
        expect(response.body).to include(%(data-appearance-theme="#{theme.id}"))
        expect(response.body).to include(%(class="theme-tile #{theme.css_class}"))
      end
    end

    it "hides the pickers a theme locks" do
      cookies["avo.theme"] = "harbor"
      get "/admin/resources/users"

      expect(response.body).not_to include("appearance#setAccent")
      expect(response.body).to include("appearance#setNeutral")
    end

    it "offers only the configured list, in order" do
      allow(appearance).to receive(:themes).and_return([:monokai, :paper])
      get "/admin/resources/users"

      ids = response.body.scan(/data-appearance-theme="([a-z_]+)"/).flatten.uniq
      expect(ids).to eq(%w[monokai paper])
    end
  end

  describe "partial overrides" do
    it "renders the theme's partial only while the theme is active, ahead of the app's own copy" do
      get "/admin/resources/users"
      expect(response.body).not_to include('data-theme-partial="lagoon"')

      cookies["avo.theme"] = "lagoon"
      get "/admin/resources/users"
      expect(response.body).to include('data-theme-partial="lagoon"')

      cookies["avo.theme"] = "harbor"
      get "/admin/resources/users"
      expect(response.body).to include('data-theme-partial="harbor"')
      expect(response.body).not_to include('data-theme-partial="lagoon"')
    end
  end

  describe "brand assets" do
    it "renders the theme's logo while active and the configured one otherwise" do
      get "/admin/resources/users"
      expect(response.body).not_to include("avo/themes/lagoon/logo")

      cookies["avo.theme"] = "lagoon"
      get "/admin/resources/users"
      expect(response.body).to include("avo/themes/lagoon/logo")
    end
  end

  describe "PATCH /admin/appearance_settings" do
    it "passes the theme to the save block" do
      received = nil
      allow(appearance).to receive_messages(save_settings_block: -> { received = settings })

      patch "/admin/appearance_settings", params: {theme: "coastal"}, as: :json

      expect(response).to have_http_status(:ok)
      expect(received).to eq(theme: "coastal")
    end
  end
end
