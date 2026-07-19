require "rails_helper"
require "benchmark"

# Unit 2 verification: with no provider registered the seams must add no
# measurable overhead. This is tracked output (the per-call nanoseconds are
# printed) guarded by a deliberately generous absolute bound so it doesn't flake
# on shared CI runners.
RSpec.describe "Dynamic config seams — null-provider overhead" do
  it "keeps the guarded config read-through negligible" do
    expect(Avo.dynamic_config_provider_installed?).to be(false)

    iterations = 200_000
    elapsed = Benchmark.realtime do
      iterations.times { Avo.configuration.per_page }
    end

    per_call_ns = (elapsed / iterations) * 1_000_000_000
    puts "[tracked] null-provider guarded config read: #{per_call_ns.round(1)} ns/call over #{iterations} calls"

    # A single `@… == true` predicate + ivar read. 5µs/call is orders of
    # magnitude of headroom above the real cost.
    expect(per_call_ns).to be < 5_000
  end

  it "keeps the guarded resource option read-through negligible" do
    resource = Avo::Resources::User.new(view: Avo::ViewInquirer.new("index"))

    iterations = 200_000
    elapsed = Benchmark.realtime do
      iterations.times { resource.title }
    end

    per_call_ns = (elapsed / iterations) * 1_000_000_000
    puts "[tracked] null-provider resource option read: #{per_call_ns.round(1)} ns/call over #{iterations} calls"

    expect(per_call_ns).to be < 5_000
  end
end
