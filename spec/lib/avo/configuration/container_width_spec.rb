require "rails_helper"

RSpec.describe Avo::Configuration, "#container_width" do
  let(:config) { described_class.new }

  after { config.instance_variable_set(:@container_width, nil) }

  describe "defaults" do
    it "returns the built-in defaults when never set" do
      expect(config.container_width).to eq({
        index: :large,
        show: :small,
        new: :small,
        edit: :small,
        create: :small,
        update: :small
      })
    end
  end

  describe "symbol input" do
    it "applies the symbol to all views" do
      config.container_width = :full
      expect(config.container_width).to eq({
        index: :full, show: :full, new: :full,
        edit: :full, create: :full, update: :full
      })
    end

    it "raises ArgumentError for an invalid symbol" do
      expect { config.container_width = :huge }.to raise_error(ArgumentError)
    end
  end

  describe "nil resets to defaults" do
    it "returns defaults after being set then reset to nil" do
      config.container_width = :full
      config.container_width = nil
      expect(config.container_width).to eq(Avo::Configuration::CONTAINER_WIDTH_DEFAULTS)
    end
  end

  describe "hash input — individual view key" do
    it "overrides only the specified view; rest keep defaults" do
      config.container_width = { index: :full }
      expect(config.container_width[:index]).to eq(:full)
      expect(config.container_width[:show]).to eq(:small)
    end
  end

  describe "hash input — group alias :forms" do
    it "expands to new, edit, create, update; index and show keep defaults" do
      config.container_width = { forms: :full }
      expect(config.container_width[:new]).to eq(:full)
      expect(config.container_width[:edit]).to eq(:full)
      expect(config.container_width[:create]).to eq(:full)
      expect(config.container_width[:update]).to eq(:full)
      expect(config.container_width[:index]).to eq(:large)
      expect(config.container_width[:show]).to eq(:small)
    end
  end

  describe "hash input — group alias :display" do
    it "expands to index and show; forms keep defaults" do
      config.container_width = { display: :full }
      expect(config.container_width[:index]).to eq(:full)
      expect(config.container_width[:show]).to eq(:full)
      expect(config.container_width[:new]).to eq(:small)
    end
  end

  describe "hash input — group alias :single" do
    it "expands to show, new, edit, create, update; index keeps default" do
      config.container_width = { single: :full }
      expect(config.container_width[:show]).to eq(:full)
      expect(config.container_width[:new]).to eq(:full)
      expect(config.container_width[:edit]).to eq(:full)
      expect(config.container_width[:create]).to eq(:full)
      expect(config.container_width[:update]).to eq(:full)
      expect(config.container_width[:index]).to eq(:large)
    end
  end

  describe "specific key wins over group alias" do
    it "specific key overrides group alias for the same view regardless of hash order" do
      config.container_width = { single: :full, show: :small }
      expect(config.container_width[:show]).to eq(:small)
      expect(config.container_width[:new]).to eq(:full)
    end
  end

  describe "invalid hash value" do
    it "raises ArgumentError" do
      expect { config.container_width = { index: :huge } }.to raise_error(ArgumentError)
    end
  end
end
