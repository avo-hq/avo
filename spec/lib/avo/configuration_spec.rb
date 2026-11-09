require "rails_helper"

RSpec.describe Avo::Configuration do
  it "blocks the admin when the license cannot be validated unless the app opts out" do
    expect(described_class.new.run_community_admin_without_valid_license).to be(false)
  end

  describe "an add-on setting whose gem is not installed" do
    it "names the gem to install" do
      expect { described_class.new.meta.fields_position = :top }
        .to raise_error(NoMethodError, /`config.meta` is provided by the avo-meta gem, which is not installed/)
      expect { described_class.new.meta = nil }.to raise_error(NoMethodError, /avo-meta gem/)
    end

    it "still answers false to respond_to?, so dummy guards keep working" do
      expect(described_class.new.respond_to?(:meta)).to be(false)
    end
  end

  it "raises the usual NoMethodError for an option no add-on provides" do
    expect { described_class.new.not_an_option }.to raise_error(NoMethodError, /undefined method/)
  end
end
