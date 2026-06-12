require "rails_helper"

RSpec.describe Avo::Fields::FrameBaseField, type: :model do
  # Pin the global association defaults so these specs assert field-level
  # behavior regardless of what the dummy app configures. Contexts that need a
  # different global config re-stub `associations` below.
  before do
    allow(Avo.configuration).to receive(:associations).and_return(
      {lookup_list_limit: 1000, frames: {loading: :lazy, auto_load_for: 15.minutes}}
    )
  end

  describe "#manual?" do
    # has_many, has_one and habtm all inherit FrameBaseField, so they share the
    # `loading:` capture and the `manual?` predicate.
    [
      Avo::Fields::HasManyField,
      Avo::Fields::HasOneField,
      Avo::Fields::HasAndBelongsToManyField
    ].each do |klass|
      context "for #{klass}" do
        it "is true with loading: :manual" do
          field = klass.new(:users, loading: :manual)

          expect(field.manual?).to be true
        end

        it "tolerates the string \"manual\"" do
          field = klass.new(:users, loading: "manual")

          expect(field.manual?).to be true
        end

        it "defaults to false when loading: is omitted" do
          field = klass.new(:users)

          expect(field.manual?).to be false
        end

        it "is false for a turbo_frame_loading: :lazy field" do
          field = klass.new(:users, turbo_frame_loading: :lazy)

          expect(field.manual?).to be false
        end
      end
    end
  end

  # Association frames fall back to `config.associations = {frames: {...}}` when
  # the field doesn't pass its own `loading:`. A per-field `loading:` always wins.
  describe "global config fallback (config.associations.frames)" do
    def field_without_loading
      Avo::Fields::HasManyField.new(:comments)
    end

    context "with the default config (loading: :lazy)" do
      it "renders the association lazily, not manually, with no memory window" do
        field = field_without_loading

        expect(field.loading_mode).to eq(:lazy)
        expect(field.lazy_loading_mode?).to be true
        expect(field.manual?).to be false
        expect(field.auto_load_for).to be_nil
      end
    end

    context "when loading is globally set to :manual" do
      before do
        allow(Avo.configuration).to receive(:associations).and_return(
          {frames: {loading: :manual, auto_load_for: 15.minutes}}
        )
      end

      it "makes un-annotated associations manual with the configured window" do
        field = field_without_loading

        expect(field.manual?).to be true
        expect(field.auto_load_for).to eq(15.minutes.to_i)
      end

      it "still lets a per-field loading: override the global default" do
        field = Avo::Fields::HasManyField.new(:comments, loading: {mode: :lazy})

        expect(field.manual?).to be false
        expect(field.lazy_loading_mode?).to be true
      end
    end

    context "when auto_load_for is globally set to 0 (opt out)" do
      before do
        allow(Avo.configuration).to receive(:associations).and_return(
          {frames: {loading: :manual, auto_load_for: 0}}
        )
      end

      it "is manual but carries no memory window" do
        field = field_without_loading

        expect(field.manual?).to be true
        expect(field.auto_load_for).to be_nil
      end
    end
  end
end
