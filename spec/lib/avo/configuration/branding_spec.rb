require "rails_helper"

RSpec.describe Avo::Configuration::Branding do
  subject(:branding) { described_class.new(options) }

  let(:options) { {} }

  describe "defaults" do
    it "defaults to auto scheme" do
      expect(branding.scheme).to eq(:auto)
    end

    it "defaults to cookie persistence" do
      expect(branding.persistence).to eq(:cookie)
    end

    it "defaults neutral and accent to nil" do
      expect(branding.neutral).to be_nil
      expect(branding.accent).to be_nil
    end

    it "defaults lock to an empty array" do
      expect(branding.lock).to eq([])
    end

    it "provides default logo and logomark" do
      expect(branding.logo).to eq("avo/logo.png")
      expect(branding.logomark).to eq("avo/logomark.png")
    end

    it "provides default favicons" do
      expect(branding.favicon).to eq("avo/favicon.ico")
      expect(branding.favicon_dark).to eq("avo/favicon-dark.ico")
    end

    it "has no load/save blocks by default" do
      expect(branding.load_settings_block).to be_nil
      expect(branding.save_settings_block).to be_nil
    end
  end

  describe "#database_persistence?" do
    it "is false by default (cookie)" do
      expect(branding).not_to be_database_persistence
    end

    context "when persistence is :database" do
      let(:options) { {persistence: :database} }

      it "is true" do
        expect(branding).to be_database_persistence
      end
    end
  end

  describe "load_settings / save_settings" do
    let(:options) do
      {
        load_settings: -> { {color_scheme: "dark"} },
        save_settings: ->(settings:, current_user:) { settings }
      }
    end

    it "stores a load_settings block" do
      expect(branding.load_settings_block).to be_a(Proc)
    end

    it "stores a save_settings block" do
      expect(branding.save_settings_block).to be_a(Proc)
    end
  end

  describe "#neutral_css_class" do
    context "with a symbol neutral" do
      let(:options) { {neutral: :slate} }

      it "returns theme-{name}" do
        expect(branding.neutral_css_class).to eq("slate")
      end
    end

    context "with a hash neutral" do
      let(:options) { {neutral: {25 => "oklch(0.99 0.01 240)"}} }

      it "returns nil" do
        expect(branding.neutral_css_class).to be_nil
      end
    end

    it "returns nil when neutral is nil" do
      expect(branding.neutral_css_class).to be_nil
    end
  end

  describe "#neutral_css_vars" do
    context "with a symbol neutral" do
      let(:options) { {neutral: :slate} }

      it "returns nil" do
        expect(branding.neutral_css_vars).to be_nil
      end
    end

    context "with a flat hash neutral" do
      let(:options) { {neutral: {25 => "oklch(0.99 0.01 240)", 50 => "oklch(0.97 0.01 240)"}} }

      it "returns CSS vars" do
        result = branding.neutral_css_vars(scheme: :light)

        expect(result).to include("--color-avo-neutral-25: oklch(0.99 0.01 240);")
        expect(result).to include("--color-avo-neutral-50: oklch(0.97 0.01 240);")
      end
    end

    context "with a light/dark hash neutral" do
      let(:options) do
        {
          neutral: {
            light: {25 => "oklch(0.99 0.01 240)"},
            dark: {25 => "oklch(0.15 0.01 240)"}
          }
        }
      end

      it "returns the correct scheme vars" do
        expect(branding.neutral_css_vars(scheme: :light)).to include("oklch(0.99 0.01 240)")
        expect(branding.neutral_css_vars(scheme: :dark)).to include("oklch(0.15 0.01 240)")
      end
    end

    it "returns nil when neutral is nil" do
      expect(branding.neutral_css_vars).to be_nil
    end
  end

  describe "#accent_css_class" do
    context "with a symbol accent" do
      let(:options) { {accent: :blue} }

      it "returns accent-{name}" do
        expect(branding.accent_css_class).to eq("blue")
      end
    end

    context "with a hash accent" do
      let(:options) { {accent: {color: "oklch(0.6 0.2 260)"}} }

      it "returns nil" do
        expect(branding.accent_css_class).to be_nil
      end
    end

    it "returns nil when accent is nil" do
      expect(branding.accent_css_class).to be_nil
    end
  end

  describe "locking behavior" do
    context "when all three are listed in lock:" do
      let(:options) { {lock: [:scheme, :neutral, :accent]} }

      it "locks all three" do
        expect(branding).to be_scheme_locked
        expect(branding).to be_neutral_locked
        expect(branding).to be_accent_locked
      end
    end

    context "when lock: is omitted" do
      it "does not lock any" do
        expect(branding).not_to be_scheme_locked
        expect(branding).not_to be_neutral_locked
        expect(branding).not_to be_accent_locked
      end
    end

    context "when only a subset is locked" do
      let(:options) { {lock: [:neutral]} }

      it "locks only that one" do
        expect(branding).to be_neutral_locked
        expect(branding).not_to be_scheme_locked
        expect(branding).not_to be_accent_locked
      end
    end

    context "when values are set but not listed in lock:" do
      let(:options) { {scheme: :dark, neutral: :slate, accent: :blue} }

      it "treats them as defaults, not locks" do
        expect(branding).not_to be_scheme_locked
        expect(branding).not_to be_neutral_locked
        expect(branding).not_to be_accent_locked
      end
    end
  end

  describe "#accent_css_vars" do
    context "with a symbol accent" do
      let(:options) { {accent: :blue} }

      it "returns nil" do
        expect(branding.accent_css_vars).to be_nil
      end
    end

    context "with a flat hash accent" do
      let(:options) do
        {
          accent: {
            color: "oklch(0.6 0.2 260)",
            content: "oklch(0.9 0.05 260)",
            foreground: "oklch(1.0 0 0)"
          }
        }
      end

      it "returns CSS vars" do
        result = branding.accent_css_vars(scheme: :light)

        expect(result).to include("--color-accent: oklch(0.6 0.2 260);")
        expect(result).to include("--color-accent-content: oklch(0.9 0.05 260);")
        expect(result).to include("--color-accent-foreground: oklch(1.0 0 0);")
      end
    end

    context "with a light/dark hash accent" do
      let(:options) do
        {
          accent: {
            light: {color: "oklch(0.6 0.2 260)", content: "oklch(0.9 0.05 260)", foreground: "oklch(1.0 0 0)"},
            dark: {color: "oklch(0.7 0.2 260)", content: "oklch(0.3 0.05 260)", foreground: "oklch(0.1 0 0)"}
          }
        }
      end

      it "returns the correct scheme vars" do
        expect(branding.accent_css_vars(scheme: :light)).to include("oklch(0.6 0.2 260)")
        expect(branding.accent_css_vars(scheme: :dark)).to include("oklch(0.7 0.2 260)")
      end
    end

    it "returns nil when accent is nil" do
      expect(branding.accent_css_vars).to be_nil
    end
  end
end
