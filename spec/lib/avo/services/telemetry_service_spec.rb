require "rails_helper"

RSpec.describe Avo::Services::TelemetryService do
  after { Avo::Current.reset }

  # Telemetry counts fields across every resource with no user in scope. It declares that
  # explicitly so a consumer that restricts fields per user opts out here, rather than
  # inferring the exemption from a nil user — nil is a legitimate user on the API surface,
  # where restriction must still apply.
  describe "marking an enumeration of every resource" do
    it "is set for the duration of the block" do
      observed = described_class.send(:enumerating_all_resources) do
        Avo::Current.enumerating_all_resources
      end

      expect(observed).to be(true)
    end

    it "restores the surrounding value rather than assuming it was unset" do
      Avo::Current.enumerating_all_resources = true

      described_class.send(:enumerating_all_resources) { :noop }

      expect(Avo::Current.enumerating_all_resources).to be(true)
    end

    it "clears the mark again when the surrounding request had not set it" do
      described_class.send(:enumerating_all_resources) { :noop }

      expect(Avo::Current.enumerating_all_resources).to be(false)
    end

    it "restores the surrounding value when the block raises" do
      expect {
        described_class.send(:enumerating_all_resources) { raise "boom" }
      }.to raise_error("boom")

      expect(Avo::Current.enumerating_all_resources).to be(false)
    end
  end
end
