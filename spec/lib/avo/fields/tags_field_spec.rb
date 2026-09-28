require "rails_helper"

RSpec.describe Avo::Fields::TagsField, type: :model do
  describe "#whitelist_items" do
    # Tagify matches tags to suggestions by their string value, so a selected
    # tag must not come back as a second entry once it's removed (#3564).
    it "does not repeat an acts_as_taggable_on tag that is already a suggestion" do
      post = create :post, tag_list: ["Dark Ride"]
      field = described_class.new(:tags, acts_as_taggable_on: :tags, suggestions: ["Coaster", "Dark Ride"])
        .hydrate(record: post, view: :edit)

      expect(JSON.parse(field.whitelist_items)).to eq ["Coaster", "Dark Ride"]
    end

    it "does not repeat a tag that matches an object suggestion's value" do
      record = Struct.new(:skills).new(["2"])
      field = described_class.new(:skills, suggestions: [{value: 1, label: "one"}, {value: 2, label: "two"}])
        .hydrate(record:, view: :edit)

      expect(JSON.parse(field.whitelist_items)).to eq [{"value" => 1, "label" => "one"}, {"value" => 2, "label" => "two"}]
    end

    it "keeps tags that are not suggestions" do
      record = Struct.new(:skills).new(["Custom"])
      field = described_class.new(:skills, suggestions: ["Coaster"]).hydrate(record:, view: :edit)

      expect(JSON.parse(field.whitelist_items)).to eq ["Coaster", "Custom"]
    end
  end
end
