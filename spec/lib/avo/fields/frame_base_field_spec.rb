require "rails_helper"

RSpec.describe Avo::Fields::FrameBaseField, type: :model do
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
end
