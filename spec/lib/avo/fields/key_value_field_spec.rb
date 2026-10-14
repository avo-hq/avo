require "rails_helper"

RSpec.describe Avo::Fields::KeyValueField, type: :model do
  describe "#suggestions" do
    let(:record) { Struct.new(:meta).new({}) }

    it "is empty by default" do
      field = described_class.new(:meta).hydrate(record:, view: :edit)

      expect(field.suggestions).to eq({})
    end

    it "turns an array of keys into keys without values" do
      field = described_class.new(:meta, suggestions: ["Content-Type", :Accept]).hydrate(record:, view: :edit)

      expect(field.suggestions).to eq({"Content-Type" => [], "Accept" => []})
    end

    it "keeps the values for each key as strings" do
      field = described_class.new(:meta, suggestions: {"Content-Type" => ["application/json", "text/html"], "Retries" => 3})
        .hydrate(record:, view: :edit)

      expect(field.suggestions).to eq({"Content-Type" => ["application/json", "text/html"], "Retries" => ["3"]})
    end

    it "evaluates a block with access to the record" do
      record = Struct.new(:meta, :name).new({}, "api")
      field = described_class.new(:meta, suggestions: -> { {"#{record.name}-key" => ["one"]} })
        .hydrate(record:, view: :edit)

      expect(field.suggestions).to eq({"api-key" => ["one"]})
    end

    it "does not add suggestions to the saved value" do
      field = described_class.new(:meta, suggestions: {"Content-Type" => ["application/json"]})

      field.fill_field(record, :meta, "{}", {})

      expect(record.meta).to eq({})
    end
  end
end
