require "rails_helper"

RSpec.describe Avo::Fields::DateTimeField, type: :model do
  describe "#fill_field" do
    let(:record) { Struct.new(:starts_at).new }
    let(:field) { described_class.new(:starts_at) }

    it "keeps the offset a value carries" do
      field.fill_field(record, :starts_at, "2026-10-22T10:00:00+03:00", {})

      expect(record.starts_at).to eq Time.utc(2026, 10, 22, 7)
    end

    it "reads a value without an offset as UTC" do
      field.fill_field(record, :starts_at, "2026-10-22 10:00", {})

      expect(record.starts_at).to eq Time.utc(2026, 10, 22, 10)
    end
  end
end
