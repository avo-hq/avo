require "rails_helper"

RSpec.describe Avo::LambdaRegistry do
  subject(:registry) { described_class.new }

  record_class = Struct.new(:name)

  describe "#register and #resolve" do
    it "makes a registered lambda resolvable by name and evaluable with request context" do
      registry.register(:greeting, label: "Greeting", description: "Says hi", kinds: [:format]) do
        "hi #{record.name}"
      end

      record = record_class.new("Ada")

      expect(registry.registered?(:greeting)).to be true
      expect(registry.resolve(:greeting, kind: :format, record: record)).to eq("hi Ada")
    end

    it "reaches current_user from the execution context" do
      registry.register(:owner_only, kinds: [:visibility]) do
        current_user.present?
      end

      user = record_class.new("Boss")

      allow(Avo::Current).to receive(:user).and_return(user)

      expect(registry.resolve(:owner_only, kind: :visibility)).to be true
    end

    it "stores the declared metadata" do
      registry.register(:active, label: "Active", description: "Active records only", kinds: %i[query scope]) {}

      entry = registry.entry(:active)

      expect(entry.label).to eq("Active")
      expect(entry.description).to eq("Active records only")
      expect(entry.kinds).to eq(%i[query scope])
      expect(registry.kinds_for(:active)).to eq(%i[query scope])
    end
  end

  describe "literal passthrough (ExecutionContext parity)" do
    it "returns a bare literal unchanged" do
      expect(registry.resolve(42, kind: :format)).to eq(42)
      expect(registry.resolve("hello", kind: :format)).to eq("hello")
      expect(registry.resolve(true, kind: :visibility)).to be true
    end

    it "evaluates an inline proc exactly like Avo::ExecutionContext" do
      record = record_class.new("Grace")
      inline = -> { record.name }

      via_registry = registry.resolve(inline, kind: :format, record: record)
      via_execution_context = Avo::ExecutionContext.new(target: inline, record: record).handle

      expect(via_registry).to eq("Grace")
      expect(via_registry).to eq(via_execution_context)
    end
  end

  describe "re-registration" do
    it "replaces the entry for the same name" do
      registry.register(:label, kinds: [:format]) { "first" }
      registry.register(:label, kinds: [:format]) { "second" }

      expect(registry.names).to eq([:label])
      expect(registry.resolve(:label, kind: :format)).to eq("second")
    end
  end

  describe "#reset (reload replay)" do
    it "drops directly-registered entries" do
      registry.register(:transient, kinds: [:format]) { "gone" }

      registry.reset

      expect(registry.registered?(:transient)).to be false
    end

    it "replays declarative registrations so they survive a reload cycle" do
      registry.declare do |r|
        r.register(:declared, label: "Declared", kinds: [:visibility]) { true }
      end

      expect(registry.registered?(:declared)).to be true

      # Simulate a to_prepare reload cycle.
      registry.reset

      expect(registry.registered?(:declared)).to be true
      expect(registry.resolve(:declared, kind: :visibility)).to be true
    end

    it "does not accumulate stale entries across repeated resets" do
      registry.declare do |r|
        r.register(:declared, kinds: [:format]) { "value" }
      end

      3.times { registry.reset }

      expect(registry.names).to eq([:declared])
    end
  end

  describe "resolution failure semantics" do
    context "gating context" do
      it "returns the fail-closed value for an unknown name" do
        expect(registry.resolve(:missing, kind: :visibility, context: :gating))
          .to eq(described_class::GATING_FAILURE)
        expect(registry.resolve(:missing, kind: :visibility, context: :gating)).to be false
      end

      it "does not log a warning when failing closed" do
        expect(Avo.logger).not_to receive(:warn)

        registry.resolve(:missing, kind: :visibility, context: :gating)
      end
    end

    context "cosmetic context" do
      it "returns the skip marker and logs exactly one warning for an unknown name" do
        expect(Avo.logger).to receive(:warn).once

        result = registry.resolve(:missing, kind: :format, context: :cosmetic)

        expect(result).to be(described_class::SKIP)
      end
    end

    it "defaults to the gating context" do
      expect(registry.resolve(:missing, kind: :visibility)).to be false
    end

    it "raises for an unknown resolution context" do
      registry.register(:foo, kinds: [:format]) { "x" }

      expect { registry.resolve(:foo, kind: :format, context: :bogus) }
        .to raise_error(ArgumentError, /Invalid resolution context/)
    end
  end

  describe "kind binding enforcement at resolve time" do
    it "fails closed for a resolvable but miskinded gating reference" do
      # A query-kind lambda would return a truthy relation and thus be always
      # visible if it were evaluated for a visibility binding.
      registry.register(:records, kinds: [:query]) { "SELECT * (truthy)" }

      expect(registry.resolve(:records, kind: :visibility, context: :gating)).to be false
    end

    it "skips with a warning for a miskinded cosmetic reference" do
      registry.register(:records, kinds: [:query]) { "truthy" }

      expect(Avo.logger).to receive(:warn).once

      expect(registry.resolve(:records, kind: :format, context: :cosmetic))
        .to be(described_class::SKIP)
    end

    it "evaluates when the requested kind is among the allowed kinds" do
      registry.register(:multi, kinds: %i[visibility format]) { "ok" }

      expect(registry.resolve(:multi, kind: :format)).to eq("ok")
      expect(registry.resolve(:multi, kind: :visibility)).to eq("ok")
    end
  end

  describe "invalid-kind registration" do
    it "raises at registration time for an unknown kind" do
      expect {
        registry.register(:bad, kinds: [:teleport]) { true }
      }.to raise_error(described_class::InvalidKindError, /Invalid lambda kind/)
    end

    it "raises when no kind is declared" do
      expect {
        registry.register(:bad, kinds: []) { true }
      }.to raise_error(described_class::InvalidKindError, /at least one kind/)
    end

    it "does not register the entry when the kind is invalid" do
      begin
        registry.register(:bad, kinds: [:teleport]) { true }
      rescue described_class::InvalidKindError
      end

      expect(registry.registered?(:bad)).to be false
    end
  end
end

RSpec.describe "Avo.lambda_registry" do
  it "exposes a memoized process-global registry" do
    expect(Avo.lambda_registry).to be_a(Avo::LambdaRegistry)
    expect(Avo.lambda_registry).to be(Avo.lambda_registry)
  end

  describe "Avo.boot integration" do
    around do |example|
      # Save and restore the global registry state so this example does not leak
      # registrations into the rest of the suite.
      saved_entries = Avo.lambda_registry.instance_variable_get(:@entries).dup
      saved_declarations = Avo.lambda_registry.instance_variable_get(:@declarations).dup

      example.run

      Avo.lambda_registry.instance_variable_set(:@entries, saved_entries)
      Avo.lambda_registry.instance_variable_set(:@declarations, saved_declarations)
    end

    it "replays an initializer-style declaration through a boot (to_prepare) cycle" do
      # Simulates what an app initializer does: declare once at configuration time.
      Avo.lambda_registry.declare do |registry|
        registry.register(:boot_declared, kinds: [:visibility]) { true }
      end

      # Simulates a to_prepare reload, which re-runs Avo.boot.
      Avo.boot

      expect(Avo.lambda_registry.registered?(:boot_declared)).to be true
    end

    it "wipes a directly-registered entry on boot" do
      Avo.lambda_registry.register(:boot_transient, kinds: [:format]) { "x" }

      Avo.boot

      expect(Avo.lambda_registry.registered?(:boot_transient)).to be false
    end
  end
end
