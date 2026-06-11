require "rails_helper"

# `Avo::Concerns::FrameLoadingMode` is mixed into both `Tab` and
# `FrameBaseField`. We exercise it through `Tab` (the lightest host that sets
# `@loading` from its kwargs) — the parsing logic is shared, so this covers the
# association fields too.
RSpec.describe Avo::Concerns::FrameLoadingMode do
  def tab(loading)
    Avo::Resources::Items::Tab.new(title: "Orders", loading: loading)
  end

  describe "no loading: given" do
    subject { Avo::Resources::Items::Tab.new(title: "Orders") }

    it "is not manual, has no mode and no memory window" do
      expect(subject.manual?).to be false
      expect(subject.lazy_loading_mode?).to be false
      expect(subject.loading_mode).to be_nil
      expect(subject.auto_load_for).to be_nil
    end
  end

  describe "symbol shorthand loading: :manual" do
    subject { tab(:manual) }

    it "is manual with no memory window (backward compatible)" do
      expect(subject.manual?).to be true
      expect(subject.loading_mode).to eq(:manual)
      expect(subject.auto_load_for).to be_nil
    end
  end

  describe "hash loading: {mode: :manual}" do
    subject { tab({mode: :manual}) }

    it "is manual with no memory window" do
      expect(subject.manual?).to be true
      expect(subject.loading_mode).to eq(:manual)
      expect(subject.auto_load_for).to be_nil
    end
  end

  describe "hash loading: {mode: :manual, auto_load_for: 5.minutes}" do
    subject { tab({mode: :manual, auto_load_for: 5.minutes}) }

    it "is manual and exposes the window in whole seconds" do
      expect(subject.manual?).to be true
      expect(subject.loading_mode).to eq(:manual)
      expect(subject.auto_load_for).to eq(300)
    end
  end

  describe "hash with auto_load_for but no explicit mode" do
    subject { tab({auto_load_for: 90}) }

    it "defaults to manual and accepts a raw integer of seconds" do
      expect(subject.manual?).to be true
      expect(subject.loading_mode).to eq(:manual)
      expect(subject.auto_load_for).to eq(90)
    end
  end

  describe "hash loading: {mode: :lazy}" do
    subject { tab({mode: :lazy}) }

    it "is lazy, not manual, and carries no memory window" do
      expect(subject.manual?).to be false
      expect(subject.lazy_loading_mode?).to be true
      expect(subject.loading_mode).to eq(:lazy)
      expect(subject.auto_load_for).to be_nil
    end
  end

  describe "string keys are tolerated" do
    subject { tab({"mode" => "manual", "auto_load_for" => 5.minutes}) }

    it "parses mode and window the same as symbol keys" do
      expect(subject.manual?).to be true
      expect(subject.auto_load_for).to eq(300)
    end
  end
end
