require "rails_helper"

RSpec.describe Avo::BaseTheme do
  describe "derived defaults for a host-app theme" do
    let(:klass) { stub_const("Avo::Themes::SeaGlass", Class.new(described_class)) }

    it "derives the id from the class name" do
      expect(klass.id).to eq(:sea_glass)
    end

    it "derives the title from the id" do
      expect(klass.title).to eq("Sea Glass")
    end

    it "derives the stylesheet path from the id" do
      expect(klass.stylesheet).to eq("avo/themes/sea_glass")
    end

    it "derives the css class from the id" do
      expect(klass.css_class).to eq("avo-theme-sea_glass")
    end

    it "has no views directory when none exists" do
      expect(klass.views).to be_nil
      expect(klass).not_to have_views
      expect(klass).not_to be_needs_visit
    end

    it "owns every picker and is drawn for the light scheme by default" do
      expect(klass.lock).to eq([:neutral, :accent, :scheme])
      expect(klass.scheme).to eq(:light)
      expect(klass).to be_forces_scheme
      expect(klass).not_to be_dark
      expect(klass.appearance).to eq({})
      expect(klass).not_to be_builtin
    end
  end

  describe "derived defaults for a gem theme" do
    it "takes the id from the gem namespace when the class is named Theme" do
      stub_const("Avo::SeaGlassTheme", Module.new)
      klass = stub_const("Avo::SeaGlassTheme::Theme", Class.new(described_class))

      expect(klass.id).to eq(:sea_glass)
      expect(klass.stylesheet).to eq("avo/themes/sea_glass")
    end
  end

  describe "explicit settings" do
    let(:klass) { stub_const("Avo::Themes::Custom", Class.new(described_class)) }

    it "accepts an explicit id, title, and stylesheet" do
      klass.id = :ocean
      klass.title = "Deep Ocean"
      klass.stylesheet = "themes/ocean"

      expect(klass.id).to eq(:ocean)
      expect(klass.title).to eq("Deep Ocean")
      expect(klass.stylesheet).to eq("themes/ocean")
      expect(klass.css_class).to eq("avo-theme-ocean")
    end

    it "allows a nil stylesheet" do
      klass.stylesheet = nil

      expect(klass.stylesheet).to be_nil
    end

    it "rejects an id that is not a css-safe token" do
      expect { klass.id = "Sea Glass" }.to raise_error(ArgumentError, /must match/)
    end

    it "accepts an explicit views directory and reports needs_visit" do
      klass.views = Rails.root.join("app/views")

      expect(klass.views).to eq(Rails.root.join("app/views"))
      expect(klass).to have_views
      expect(klass).to be_needs_visit
    end

    it "accepts neutral, accent, and scheme locks only" do
      klass.lock = [:neutral, "accent"]
      expect(klass.lock).to eq([:neutral, :accent])
      expect(klass.locks?(:neutral)).to be(true)
      expect(klass).not_to be_forces_scheme

      klass.lock = []
      expect(klass.lock).to eq([])

      expect { klass.lock = [:theme] }.to raise_error(ArgumentError, /accepts/)
    end

    it "accepts a light or dark scheme and nothing else" do
      klass.scheme = "dark"
      expect(klass.scheme).to eq(:dark)
      expect(klass).to be_dark

      expect { klass.scheme = :auto }.to raise_error(ArgumentError, /accepts/)
    end

    it "accepts brand-asset appearance keys and rejects everything else" do
      klass.appearance = {"logo" => "x.png", :chart_colors => %w[#000]}
      expect(klass.appearance).to eq(logo: "x.png", chart_colors: %w[#000])
      expect(klass).to be_needs_visit

      expect { klass.appearance = {neutral: :slate} }.to raise_error(ArgumentError, /Colors belong in the theme's stylesheet/)
    end

    it "inherits settings through a theme subclass" do
      klass.title = "Parent"
      klass.lock = [:accent]
      klass.scheme = :dark
      child = stub_const("Avo::Themes::Child", Class.new(klass))

      expect(child.id).to eq(:child)
      expect(child.title).to eq("Parent")
      expect(child.lock).to eq([:accent])
      expect(child.scheme).to eq(:dark)
    end
  end
end
