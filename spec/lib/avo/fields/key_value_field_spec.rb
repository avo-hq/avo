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

  describe "#fill_field with disabled parts" do
    let(:record) { Struct.new(:meta).new({"foo" => "bar", "hey" => "hi"}) }

    def submit(field, value)
      field.fill_field(record, :meta, value.to_json, {})
      record.meta
    end

    it "keeps the stored values when editing values is disabled" do
      field = described_class.new(:meta, disable_editing_values: true)

      expect(submit(field, {"foo" => "changed", "hey" => "hi", "new" => "value"}))
        .to eq({"foo" => "bar", "hey" => "hi", "new" => ""})
    end

    it "drops new keys when adding rows is disabled" do
      field = described_class.new(:meta, disable_adding_rows: true)

      expect(submit(field, {"foo" => "changed", "hey" => "hi", "new" => "value"}))
        .to eq({"foo" => "changed", "hey" => "hi"})
    end

    it "keeps removed keys when deleting rows is disabled" do
      field = described_class.new(:meta, disable_deleting_rows: true)

      expect(submit(field, {"hey" => "hi"})).to eq({"hey" => "hi", "foo" => "bar"})
    end

    it "compares a new record against the field's default" do
      record = Struct.new(:meta) { def new_record? = true }.new(nil)
      field = described_class.new(:meta, default: {"foo" => "bar"}, disable_adding_rows: true)

      field.fill_field(record, :meta, {"foo" => "changed", "new" => "value"}.to_json, {})

      expect(record.meta).to eq({"foo" => "changed"})
    end
  end
end
