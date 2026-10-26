require "rails_helper"

RSpec.describe Avo::Configuration, "#container_width" do
  let(:config) { described_class.new }

  describe "defaults" do
    it "returns the built-in defaults when never set" do
      expect(config.container_width).to eq({
        index: :lg,
        show: :md,
        new: :md,
        edit: :md,
        create: :md,
        update: :md
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

    it "applies :lg to all views" do
      config.container_width = :lg
      expect(config.container_width.values.uniq).to eq([:lg])
    end

    it "applies :md to all views" do
      config.container_width = :md
      expect(config.container_width.values.uniq).to eq([:md])
    end

    it "applies :sm to all views" do
      config.container_width = :sm
      expect(config.container_width.values.uniq).to eq([:sm])
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
      config.container_width = {index: :full}
      expect(config.container_width[:index]).to eq(:full)
      expect(config.container_width[:show]).to eq(:md)
    end
  end

  describe "hash input — group alias :forms" do
    it "expands to new, edit, create, update; index and show keep defaults" do
      config.container_width = {forms: :full}
      expect(config.container_width[:new]).to eq(:full)
      expect(config.container_width[:edit]).to eq(:full)
      expect(config.container_width[:create]).to eq(:full)
      expect(config.container_width[:update]).to eq(:full)
      expect(config.container_width[:index]).to eq(:lg)
      expect(config.container_width[:show]).to eq(:md)
    end
  end

  describe "hash input — group alias :display" do
    it "expands to index and show; forms keep defaults" do
      config.container_width = {display: :full}
      expect(config.container_width[:index]).to eq(:full)
      expect(config.container_width[:show]).to eq(:full)
      expect(config.container_width[:new]).to eq(:md)
    end
  end

  describe "hash input — group alias :single" do
    it "expands to show, new, edit, create, update; index keeps default" do
      config.container_width = {single: :full}
      expect(config.container_width[:show]).to eq(:full)
      expect(config.container_width[:new]).to eq(:full)
      expect(config.container_width[:edit]).to eq(:full)
      expect(config.container_width[:create]).to eq(:full)
      expect(config.container_width[:update]).to eq(:full)
      expect(config.container_width[:index]).to eq(:lg)
    end
  end

  describe "specific key wins over group alias" do
    it "specific key overrides group alias for the same view regardless of hash order" do
      config.container_width = {single: :full, show: :md}
      expect(config.container_width[:show]).to eq(:md)
      expect(config.container_width[:new]).to eq(:full)
    end
  end

  describe "invalid hash value" do
    it "raises ArgumentError" do
      expect { config.container_width = {index: :huge} }.to raise_error(ArgumentError)
    end
  end

  describe "invalid hash key" do
    it "raises ArgumentError for an unrecognised view key" do
      expect { config.container_width = {idnex: :full} }.to raise_error(ArgumentError)
    end
  end

  describe "deprecated width names" do
    before { allow(Avo.logger).to receive(:warn) }

    it "maps :large to :lg and warns" do
      config.container_width = :large

      expect(config.container_width.values.uniq).to eq([:lg])
      expect(Avo.logger).to have_received(:warn).with(/`:large` is deprecated.*Use `:lg`/)
    end

    it "maps :small to :md, not to the new :sm" do
      config.container_width = :small

      expect(config.container_width.values.uniq).to eq([:md])
      expect(Avo.logger).to have_received(:warn).with(/`:small` is deprecated.*Use `:md`/)
    end

    it "maps them inside a hash, group aliases included" do
      config.container_width = {index: :small, forms: :large}

      expect(config.container_width[:index]).to eq(:md)
      expect(config.container_width[:new]).to eq(:lg)
      expect(config.container_width[:show]).to eq(:md)
    end
  end
end
