require "rails_helper"

RSpec.describe "Avo boot" do
  it "evaluates the host app's Avo initializer once" do
    expect(ENV["AVO_DUMMY_INITIALIZER_RUNS"]).to eq "1"
  end
end
