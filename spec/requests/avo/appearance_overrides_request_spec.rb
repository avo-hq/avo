require "rails_helper"

RSpec.describe "Appearance overrides", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before { login_as admin_user }

  context "when neither neutral_colors nor accent_colors is configured" do
    before do
      allow(Avo.configuration.appearance).to receive(:brand_css_overrides).and_return(nil)
    end

    it "renders no brand-override style declarations" do
      get "/admin/failed_to_load"

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("--color-avo-neutral-25:")
      expect(response.body).not_to include("--color-accent:")
    end
  end

  context "when overrides are configured" do
    let(:overrides_css) do
      <<~CSS
        @layer base {
          :root {
            --color-avo-neutral-25: oklch(0.99 0.01 240);
            --color-accent: oklch(0.6 0.2 260);
          }
        }
      CSS
    end

    before do
      allow(Avo.configuration.appearance).to receive(:brand_css_overrides).and_return(overrides_css)
    end

    it "emits the inline style tag with the override declarations" do
      get "/admin/failed_to_load"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("--color-avo-neutral-25: oklch(0.99 0.01 240);")
      expect(response.body).to include("--color-accent: oklch(0.6 0.2 260);")
      expect(response.body).to match(%r{<style\b[^>]*>.*--color-avo-neutral-25.*</style>}m)
    end

    it "preserves the favicon link tag emitted by the appearance partial" do
      get "/admin/failed_to_load"

      expect(response.body).to include('rel="icon"')
    end
  end

  context "when a main content background is configured" do
    let(:overrides_css) do
      <<~CSS
        @layer base {
          :root {
            --main-content-background: url('/bg.png') center/cover no-repeat;
          }
        }
      CSS
    end

    before do
      allow(Avo.configuration.appearance).to receive(:brand_css_overrides).and_return(overrides_css)
    end

    it "emits the --main-content-background declaration inside a style tag" do
      get "/admin/failed_to_load"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("--main-content-background: url('/bg.png') center/cover no-repeat;")
      expect(response.body).to match(%r{<style\b[^>]*>.*--main-content-background.*</style>}m)
    end
  end
end
