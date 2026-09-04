require "rails_helper"

RSpec.describe Avo::Themes::Manager do
  subject(:manager) { Avo.theme_manager }

  it "registers the built-ins first, in their shipped order" do
    expect(manager.all.first(13)).to eq(Avo::BuiltinThemes.all)
    expect(manager.ids.first).to eq(:paper)
  end

  it "discovers the dummy app's local theme and the gem-shaped fixture theme" do
    expect(manager.find(:lagoon)).to eq(Avo::Themes::Lagoon)
    expect(manager.find(:harbor)).to eq(Avo::HarborTheme::Theme)
    expect(manager.installed?("harbor")).to be(true)
    expect(manager.installed?(:nope)).to be(false)
  end

  it "sorts installed themes by title after the built-ins" do
    expect(manager.all.drop(13)).to eq([Avo::HarborTheme::Theme, Avo::Themes::Lagoon])
  end

  it "links only non-built-in stylesheets" do
    expect(manager.stylesheets).to eq(["avo/themes/harbor", "avo/themes/lagoon"])
  end

  it "resolves the gem theme's views directory from its engine root" do
    expect(Avo::HarborTheme::Theme.views.to_s).to end_with("vendor/avo-harbor_theme/app/views/avo/themes/harbor")
    expect(Avo::Themes::Lagoon.views.to_s).to end_with("spec/dummy/app/views/avo/themes/lagoon")
  end

  it "raises when two themes claim one id" do
    fresh = described_class.new
    fresh.register(Avo::BuiltinThemes::Coastal)
    imposter = stub_const("Avo::Themes::Coastal", Class.new(Avo::BaseTheme))

    expect { fresh.register(imposter) }.to raise_error(ArgumentError, /Two themes claim the id :coastal.*Avo::BuiltinThemes::Coastal.*Avo::Themes::Coastal/)
  end

  describe "offered themes" do
    it "offers everything by default and defaults to Paper" do
      expect(manager.offered).to eq(manager.all)
      expect(manager.default).to eq(Avo::BuiltinThemes::Paper)
    end

    it "honors the configured list and order, dropping unknown ids" do
      allow(Avo.configuration.appearance).to receive(:themes).and_return([:monokai, :lagoon, :nope])

      expect(manager.offered_ids).to eq([:monokai, :lagoon])
      expect(manager.offered?(:paper)).to be(false)
    end

    it "falls back to the first offered theme when Paper is not offered" do
      allow(Avo.configuration.appearance).to receive(:themes).and_return([:monokai, :lagoon])
      allow(Avo.configuration.appearance).to receive(:theme).and_return(nil)

      expect(manager.default).to eq(Avo::BuiltinThemes::Monokai)
    end

    it "prefers the configured default theme" do
      allow(Avo.configuration.appearance).to receive(:theme).and_return(:dracula)

      expect(manager.default).to eq(Avo::BuiltinThemes::Dracula)
    end
  end
end
