require "rails_helper"

RSpec.describe Avo::Current do
  after { described_class.reset }

  describe ".interface" do
    # Names the client a request arrived through, so one authorization answer can differ
    # per surface. Distinct from `view`, which is a screen within one surface.
    it "reads :ui when nothing has set it" do
      expect(described_class.interface).to eq(:ui)
    end

    it "carries a value that was set" do
      described_class.interface = :api

      expect(described_class.interface).to eq(:api)
    end

    it "returns to :ui after a reset rather than to nil" do
      described_class.interface = :mcp
      described_class.reset

      expect(described_class.interface).to eq(:ui)
    end

    # Rails 7.1's CurrentAttributes#attribute takes no `default:` keyword, so declaring the
    # default that way raises at class-definition time. This asserts the class loaded and the
    # default arrived through `resets` + `initialize`, the way `appearance_settings` does.
    it "declares the default without the default: keyword" do
      expect(described_class.new.interface).to eq(:ui)
    end
  end

  describe ".enumerating_all_resources" do
    # Set by the callers that map over every resource with no user in scope — core's telemetry
    # and avo-licensing's debug service. Consumers that restrict fields per user read this to
    # opt out explicitly, so the exemption can never be inferred from a nil user.
    it "is false when nothing has set it" do
      expect(described_class.enumerating_all_resources).to be(false)
    end

    it "carries a value that was set" do
      described_class.enumerating_all_resources = true

      expect(described_class.enumerating_all_resources).to be(true)
    end

    it "returns to false after a reset rather than to nil" do
      described_class.enumerating_all_resources = true
      described_class.reset

      expect(described_class.enumerating_all_resources).to be(false)
    end
  end
end
