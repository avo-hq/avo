require "rails_helper"

RSpec.describe Avo::Configuration, "#tailwindcss_content_sources" do
  let(:config) { described_class.new }

  it "defaults to app under Rails.root when unset" do
    expect(config.tailwindcss_content_sources).to eq([Rails.root.join("app")])
  end

  it "returns the configured list when set" do
    config.tailwindcss_content_sources = ["lib", Rails.root.join("config")]
    expect(config.tailwindcss_content_sources).to eq(["lib", Rails.root.join("config")])
  end
end
