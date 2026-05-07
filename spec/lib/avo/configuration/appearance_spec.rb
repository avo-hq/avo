require "rails_helper"

RSpec.describe Avo::Configuration::Appearance do
  subject(:appearance) { described_class.new(options) }

  let(:options) { {} }

  describe "defaults" do
    it "defaults to auto scheme" do
      expect(appearance.scheme).to eq(:auto)
    end

    it "defaults to cookie persistence" do
      expect(appearance.persistence).to eq(:cookie)
    end

    it "defaults neutral and accent to nil" do
      expect(appearance.neutral).to be_nil
      expect(appearance.accent).to be_nil
    end

    it "defaults neutral_colors and accent_colors to nil" do
      expect(appearance.neutral_colors).to be_nil
      expect(appearance.accent_colors).to be_nil
    end

    it "defaults lock to an empty array" do
      expect(appearance.lock).to eq([])
    end

    it "provides default logo and logomark" do
      expect(appearance.logo).to eq("avo/logo.png")
      expect(appearance.logomark).to eq("avo/logomark.png")
    end

    it "provides default favicons" do
      expect(appearance.favicon).to eq("avo/favicon.ico")
      expect(appearance.favicon_dark).to eq("avo/favicon-dark.ico")
    end

    it "has no load/save blocks by default" do
      expect(appearance.load_settings_block).to be_nil
      expect(appearance.save_settings_block).to be_nil
    end
  end

  describe "#database_persistence?" do
    it "is false by default (cookie)" do
      expect(appearance).not_to be_database_persistence
    end

    context "when persistence is :database" do
      let(:options) { {persistence: :database} }

      it "is true" do
        expect(appearance).to be_database_persistence
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
      expect(appearance.load_settings_block).to be_a(Proc)
    end

    it "stores a save_settings block" do
      expect(appearance.save_settings_block).to be_a(Proc)
    end
  end

  describe "#neutral_css_class" do
    it "returns the symbol name as a string" do
      expect(described_class.new(neutral: :slate).neutral_css_class).to eq("slate")
    end

    it "returns nil when neutral is nil" do
      expect(appearance.neutral_css_class).to be_nil
    end
  end

  describe "#accent_css_class" do
    it "returns the symbol name as a string" do
      expect(described_class.new(accent: :blue).accent_css_class).to eq("blue")
    end

    it "returns nil when accent is nil" do
      expect(appearance.accent_css_class).to be_nil
    end
  end

  describe "selection validation" do
    it "raises a migration-hint error when neutral is a Hash" do
      expect { described_class.new(neutral: {25 => "oklch(0.99 0.01 240)"}) }
        .to raise_error(ArgumentError, /appearance\.neutral accepts a Symbol.*neutral_colors:/m)
    end

    it "raises a migration-hint error when accent is a Hash" do
      expect { described_class.new(accent: {color: "oklch(0.6 0.2 260)"}) }
        .to raise_error(ArgumentError, /appearance\.accent accepts a Symbol.*accent_colors:/m)
    end

    it "raises when neutral is an unsupported type" do
      expect { described_class.new(neutral: 42) }
        .to raise_error(ArgumentError, /appearance\.neutral must be a Symbol/)
    end

    it "raises when neutral is a String (Symbol-only contract)" do
      expect { described_class.new(neutral: "slate") }
        .to raise_error(ArgumentError, /appearance\.neutral must be a Symbol/)
    end
  end

  describe "locking behavior" do
    context "when all three are listed in lock:" do
      let(:options) { {lock: [:scheme, :neutral, :accent]} }

      it "locks all three" do
        expect(appearance).to be_scheme_locked
        expect(appearance).to be_neutral_locked
        expect(appearance).to be_accent_locked
      end
    end

    context "when lock: is omitted" do
      it "does not lock any" do
        expect(appearance).not_to be_scheme_locked
        expect(appearance).not_to be_neutral_locked
        expect(appearance).not_to be_accent_locked
      end
    end

    context "when only a subset is locked" do
      let(:options) { {lock: [:neutral]} }

      it "locks only that one" do
        expect(appearance).to be_neutral_locked
        expect(appearance).not_to be_scheme_locked
        expect(appearance).not_to be_accent_locked
      end
    end

    context "when values are set but not listed in lock:" do
      let(:options) { {scheme: :dark, neutral: :slate, accent: :blue} }

      it "treats them as defaults, not locks" do
        expect(appearance).not_to be_scheme_locked
        expect(appearance).not_to be_neutral_locked
        expect(appearance).not_to be_accent_locked
      end
    end
  end

  describe "neutral_colors / accent_colors" do
    let(:complete_neutral) do
      {
        light: described_class::NEUTRAL_SHADES.each_with_object({}) { |s, h| h[s] = "oklch(0.99 0.01 240)" },
        dark: described_class::NEUTRAL_SHADES.each_with_object({}) { |s, h| h[s] = "oklch(0.15 0.01 240)" }
      }
    end

    let(:complete_accent) do
      {
        light: {color: "oklch(0.6 0.2 260)", content: "oklch(0.5 0.2 260)", foreground: "oklch(1 0 0)"},
        dark: {color: "oklch(0.7 0.2 260)", content: "oklch(0.8 0.2 260)", foreground: "oklch(0.1 0 0)"}
      }
    end

    describe "accessors" do
      let(:options) { {neutral_colors: complete_neutral, accent_colors: complete_accent} }

      it "exposes neutral_colors verbatim" do
        expect(appearance.neutral_colors).to eq(complete_neutral)
      end

      it "exposes accent_colors verbatim" do
        expect(appearance.accent_colors).to eq(complete_accent)
      end
    end

    describe "validation of neutral_colors" do
      it "raises when not a Hash" do
        expect { described_class.new(neutral_colors: "nope") }
          .to raise_error(ArgumentError, /neutral_colors must be a Hash/)
      end

      it "raises when :dark is missing entirely" do
        expect { described_class.new(neutral_colors: {light: complete_neutral[:light]}) }
          .to raise_error(ArgumentError, /missing scheme :dark/)
      end

      it "raises and names missing shades" do
        partial = {light: complete_neutral[:light].except(100, 700), dark: complete_neutral[:dark]}

        expect { described_class.new(neutral_colors: partial) }
          .to raise_error(ArgumentError, /:light missing shades \[100, 700\]/)
      end

      it "treats nil shade values as missing" do
        partial = {light: complete_neutral[:light].merge(500 => nil), dark: complete_neutral[:dark]}

        expect { described_class.new(neutral_colors: partial) }
          .to raise_error(ArgumentError, /:light missing shades \[500\]/)
      end

      it "raises when a scheme is not a Hash" do
        expect { described_class.new(neutral_colors: {light: complete_neutral[:light], dark: "nope"}) }
          .to raise_error(ArgumentError, /:dark must be a Hash/)
      end
    end

    describe "validation of accent_colors" do
      it "raises when :foreground is missing in :light" do
        partial = {
          light: complete_accent[:light].except(:foreground),
          dark: complete_accent[:dark]
        }

        expect { described_class.new(accent_colors: partial) }
          .to raise_error(ArgumentError, /:light missing tokens \[:foreground\]/)
      end

      it "raises when :dark is missing entirely" do
        expect { described_class.new(accent_colors: {light: complete_accent[:light]}) }
          .to raise_error(ArgumentError, /missing scheme :dark/)
      end
    end

    describe "#brand_css_overrides" do
      it "returns nil when neither key is configured" do
        expect(appearance.brand_css_overrides).to be_nil
      end

      context "when only neutral_colors is configured" do
        let(:options) { {neutral_colors: complete_neutral} }

        it "emits :root and .dark blocks with all 12 neutral shades inside @layer base" do
          css = appearance.brand_css_overrides

          expect(css).to start_with("@layer base {")
          expect(css.strip).to end_with("}")
          expect(css).to include(":root {")
          expect(css).to include(".dark {")
          described_class::NEUTRAL_SHADES.each do |shade|
            expect(css).to include("--color-avo-neutral-#{shade}: oklch(0.99 0.01 240);")
            expect(css).to include("--color-avo-neutral-#{shade}: oklch(0.15 0.01 240);")
          end
        end

        it "emits the brand-scoped --color-brand-neutral-400 alias for the picker swatch" do
          css = appearance.brand_css_overrides

          expect(css).to include("--color-brand-neutral-400: oklch(0.99 0.01 240);")
          expect(css).to include("--color-brand-neutral-400: oklch(0.15 0.01 240);")
        end

        it "does not emit accent declarations" do
          css = appearance.brand_css_overrides

          expect(css).not_to include("--color-accent")
          expect(css).not_to include("--color-brand-accent")
        end
      end

      context "when only accent_colors is configured" do
        let(:options) { {accent_colors: complete_accent} }

        it "emits all three accent tokens for both schemes" do
          css = appearance.brand_css_overrides

          expect(css).to include("--color-accent: oklch(0.6 0.2 260);")
          expect(css).to include("--color-accent-content: oklch(0.5 0.2 260);")
          expect(css).to include("--color-accent-foreground: oklch(1 0 0);")
          expect(css).to include("--color-accent: oklch(0.7 0.2 260);")
          expect(css).to include("--color-accent-content: oklch(0.8 0.2 260);")
        end

        it "emits the brand-scoped --color-brand-accent alias for the picker swatch" do
          css = appearance.brand_css_overrides

          expect(css).to include("--color-brand-accent: oklch(0.6 0.2 260);")
          expect(css).to include("--color-brand-accent: oklch(0.7 0.2 260);")
        end

        it "does not emit neutral declarations" do
          css = appearance.brand_css_overrides

          expect(css).not_to include("--color-avo-neutral-")
          expect(css).not_to include("--color-brand-neutral-")
        end
      end

      context "when both keys are configured" do
        let(:options) { {neutral_colors: complete_neutral, accent_colors: complete_accent} }

        it "emits both palettes inside a single :root and a single .dark block" do
          css = appearance.brand_css_overrides

          expect(css.scan(":root {").size).to eq(1)
          expect(css.scan(".dark {").size).to eq(1)
          expect(css).to include("--color-avo-neutral-25: oklch(0.99 0.01 240);")
          expect(css).to include("--color-accent-foreground: oklch(1 0 0);")
        end
      end
    end
  end
end
