require "rails_helper"

RSpec.describe Avo::Configuration::Branding do
  subject(:branding) { described_class.new }

  describe "defaults" do
    it "defaults to static mode" do
      expect(branding.mode).to eq(:static)
    end

    it "defaults to auto scheme" do
      expect(branding.default_scheme).to eq(:auto)
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

    it "is dynamic when mode is :dynamic" do
      branding.mode = :dynamic
      expect(branding).to be_dynamic
      expect(branding).not_to be_static
    end
  end

  describe "#database_persistence?" do
    it "is false by default (localstorage)" do
      expect(branding).not_to be_database_persistence
    end

    it "is true when persistence is :database" do
      branding.persistence = :database
      expect(branding).to be_database_persistence
    end
  end

  describe "#effective_mode" do
    it "returns the current mode" do
      expect(branding.effective_mode).to eq(:static)
      branding.mode = :dynamic
      expect(branding.effective_mode).to eq(:dynamic)
    end
  end

  describe "#load_settings / #save_settings" do
    it "stores a load_settings block" do
      branding.load_settings { {color_scheme: "dark"} }
      expect(branding.load_settings_block).to be_a(Proc)
    end

    it "stores a save_settings block" do
      branding.save_settings { |settings| settings }
      expect(branding.save_settings_block).to be_a(Proc)
    end
  end

  describe "#neutral_css_class" do
    it "returns theme-{name} for a symbol neutral" do
      branding.neutral = :slate
      expect(branding.neutral_css_class).to eq("theme-slate")
    end

    it "returns nil when neutral is a hash" do
      branding.neutral = {25 => "oklch(0.99 0.01 240)"}
      expect(branding.neutral_css_class).to be_nil
    end

    it "returns nil when neutral is nil" do
      expect(branding.neutral_css_class).to be_nil
    end
  end

  describe "#neutral_css_vars" do
    it "returns nil for symbol neutral" do
      branding.neutral = :slate
      expect(branding.neutral_css_vars).to be_nil
    end

    it "returns CSS vars for a flat hash neutral" do
      branding.neutral = {25 => "oklch(0.99 0.01 240)", 50 => "oklch(0.97 0.01 240)"}
      result = branding.neutral_css_vars(scheme: :light)

      expect(result).to include("--color-avo-neutral-25: oklch(0.99 0.01 240);")
      expect(result).to include("--color-avo-neutral-50: oklch(0.97 0.01 240);")
    end

    it "returns light scheme vars for a light/dark hash" do
      branding.neutral = {
        light: {25 => "oklch(0.99 0.01 240)"},
        dark: {25 => "oklch(0.15 0.01 240)"}
      }

      light_result = branding.neutral_css_vars(scheme: :light)
      dark_result = branding.neutral_css_vars(scheme: :dark)

      expect(light_result).to include("oklch(0.99 0.01 240)")
      expect(dark_result).to include("oklch(0.15 0.01 240)")
    end

    it "returns nil when neutral is nil" do
      expect(branding.neutral_css_vars).to be_nil
    end
  end

  describe "#accent_css_class" do
    it "returns accent-{name} for a symbol accent" do
      branding.accent = :blue
      expect(branding.accent_css_class).to eq("accent-blue")
    end

    it "returns nil when accent is a hash" do
      branding.accent = {color: "oklch(0.6 0.2 260)"}
      expect(branding.accent_css_class).to be_nil
    end

    it "returns nil when accent is nil" do
      expect(branding.accent_css_class).to be_nil
    end
  end

  describe "#accent_css_vars" do
    it "returns nil for symbol accent" do
      branding.accent = :blue
      expect(branding.accent_css_vars).to be_nil
    end

    it "returns CSS vars for a flat hash accent" do
      branding.accent = {
        color: "oklch(0.6 0.2 260)",
        content: "oklch(0.9 0.05 260)",
        foreground: "oklch(1.0 0 0)"
      }
      result = branding.accent_css_vars(scheme: :light)

      expect(result).to include("--color-accent: oklch(0.6 0.2 260);")
      expect(result).to include("--color-accent-content: oklch(0.9 0.05 260);")
      expect(result).to include("--color-accent-foreground: oklch(1.0 0 0);")
    end

    it "returns light/dark scheme vars for a light/dark hash" do
      branding.accent = {
        light: {color: "oklch(0.6 0.2 260)", content: "oklch(0.9 0.05 260)", foreground: "oklch(1.0 0 0)"},
        dark: {color: "oklch(0.7 0.2 260)", content: "oklch(0.3 0.05 260)", foreground: "oklch(0.1 0 0)"}
      }

      light_result = branding.accent_css_vars(scheme: :light)
      dark_result = branding.accent_css_vars(scheme: :dark)

      expect(light_result).to include("oklch(0.6 0.2 260)")
      expect(dark_result).to include("oklch(0.7 0.2 260)")
    end

    it "returns nil when accent is nil" do
      expect(branding.accent_css_vars).to be_nil
    end
  end
end
