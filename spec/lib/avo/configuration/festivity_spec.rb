require "rails_helper"

RSpec.describe "Avo.configuration.festivity" do
  subject(:config) { Avo::Configuration.new }

  it "defaults to nil" do
    expect(config.festivity).to be_nil
  end

  it "accepts :christmas" do
    config.festivity = :christmas

    expect(config.festivity).to eq(:christmas)
  end

  # Year-versioned symbols are not festivities: a new one is a new entry in the list.
  [:christmas_2024, :easter, "christmas", true].each do |value|
    it "raises on #{value.inspect}, listing the valid values" do
      expect { config.festivity = value }
        .to raise_error(ArgumentError, /festivity must be nil, :christmas or a lambda, got #{Regexp.escape(value.inspect)}/)
    end
  end

  describe "a lambda" do
    it "is resolved on each read, with the request's context" do
      config.festivity = -> { :christmas if params[:month] == "12" }

      allow(Avo::Current).to receive(:params).and_return({month: "12"})
      expect(config.festivity).to eq(:christmas)

      allow(Avo::Current).to receive(:params).and_return({month: "6"})
      expect(config.festivity).to be_nil
    end

    # Never raises at request time: a bad lambda result only switches the festivity off.
    it "warns and resolves to nil when it returns an unknown value" do
      config.festivity = -> { :christmas_2024 }
      allow(Avo.logger).to receive(:warn)

      expect(config.festivity).to be_nil
      expect(Avo.logger).to have_received(:warn)
        .with(/config\.festivity returned :christmas_2024.*nil, :christmas/)
    end
  end

  describe "locking" do
    it "is lockable through appearance.lock" do
      expect(Avo::Configuration::Appearance::LOCKABLE).to include(:festivity)
      expect(Avo::Configuration::Appearance.new(lock: [:festivity])).to be_festivity_locked
      expect(Avo::Configuration::Appearance.new).not_to be_festivity_locked
    end
  end

  describe "preference keys" do
    it "names one stored opt-out per festivity" do
      expect(Avo::Configuration::Appearance.new.festivity_preference_keys).to eq(["festivity_christmas"])
    end
  end

  describe "toggle icons" do
    it "gives every festivity an on and an off icon" do
      Avo::Configuration::FESTIVITIES.each do |festivity|
        expect(Avo::Configuration::FESTIVITY_ICONS.fetch(festivity).keys).to contain_exactly(:on, :off)
      end
    end
  end
end
