require "rails_helper"

RSpec.describe Avo::Configuration do
  it "blocks the admin when the license cannot be validated unless the app opts out" do
    expect(described_class.new.run_community_admin_without_valid_license).to be(false)
  end
end
