require "rails_helper"

RSpec.describe Avo::Configuration::Branding do
  subject(:branding) { described_class.new(options) }

  let(:options) { {} }

  describe "defaults" do
    it "defaults to static mode" do
      expect(branding.mode).to eq(:static)
    end

    it "defaults to auto scheme" do
      expect(branding.scheme).to eq(:auto)
    end

    it "defaults to localstorage persistence" do
      expect(branding.persistence).to eq(:localstorage)
    end

    it "defaults neutral and accent to nil" do
      expect(branding.neutral).to be_nil
      expect(branding.accent).to be_nil
    end

    it "provides default logo and logomark" do
      expect(branding.logo).to eq("avo/logo.png")
      expect(branding.logomark).to eq("avo/logomark.png")
    end

    it "has no load/save blocks by default" do
      expect(branding.load_settings_block).to be_nil
      expect(branding.save_settings_block).to be_nil
    end
  end

  describe "#static? / #dynamic?" do
    it "is static by default" do
      expect(branding).to be_static
      expect(branding).not_to be_dynamic
    end

    context "when mode is :dynamic" do
      let(:options) { {mode: :dynamic} }

      it "is dynamic" do
        expect(branding).to be_dynamic
        expect(branding).not_to be_static
      end
    end
  end

  describe "#database_persistence?" do
    it "is false by default (localstorage)" do
      expect(branding).not_to be_database_persistence
    end

    context "when persistence is :database" do
      let(:options) { {persistence: :database} }

      it "is true" do
        expect(branding).to be_database_persistence
      end
    end
  end

  describe "#effective_mode" do
    it "returns the current mode" do
      expect(branding.effective_mode).to eq(:static)
    end

    context "when mode is :dynamic" do
      let(:options) { {mode: :dynamic} }

      it "returns :dynamic" do
        expect(branding.effective_mode).to eq(:dynamic)
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
    context "in static mode with values explicitly set" do
      let(:options) { {mode: :static, scheme: :dark, neutral: :slate, accent: :blue} }

      it "locks all three" do
        expect(branding).to be_scheme_locked
        expect(branding).to be_neutral_locked
        expect(branding).to be_accent_locked
      end
    end

    context "in static mode without values set" do
      let(:options) { {mode: :static} }

      it "does not lock any" do
        expect(branding).not_to be_scheme_locked
        expect(branding).not_to be_neutral_locked
        expect(branding).not_to be_accent_locked
      end
    end

    context "in dynamic mode with values explicitly set" do
      let(:options) { {mode: :dynamic, scheme: :dark, neutral: :slate, accent: :blue} }

      it "does not lock any (values are defaults)" do
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
