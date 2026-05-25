require "rails_helper"

RSpec.describe Avo::Fields::CheckboxListField, type: :model do
  let(:resource) { double("resource") }
  let(:view) { Avo::ViewInquirer.new(:edit) }

  describe "#options" do
    it "returns array literal options" do
      options = [{id: 1, title: "A"}]
      field = described_class.new(:addon_ids, options: options).hydrate(resource:, view:)

      expect(field.options).to eq options
    end

    it "evaluates callable options in the field execution context" do
      record = Struct.new(:id).new(42)
      field = described_class.new(:addon_ids, options: -> { [{id: record.id, title: "Record #{record.id}"}] })
        .hydrate(record:, resource:, view:)

      expect(field.options).to eq [{id: 42, title: "Record 42"}]
    end

    it "memoizes options per hydration" do
      calls = 0
      field = described_class.new(:addon_ids, options: -> {
        calls += 1
        [{id: record.id, title: "Record #{record.id}"}]
      })

      field.hydrate(record: Struct.new(:id).new(1), resource:, view:)

      expect(field.options).to eq [{id: 1, title: "Record 1"}]
      expect(field.options).to eq [{id: 1, title: "Record 1"}]
      expect(calls).to eq 1

      field.hydrate(record: Struct.new(:id).new(2), resource:, view:)

      expect(field.options).to eq [{id: 2, title: "Record 2"}]
      expect(calls).to eq 2
    end

    it "propagates errors from callable options" do
      field = described_class.new(:addon_ids, options: -> { raise "boom" }).hydrate(resource:, view:)

      expect { field.options }.to raise_error RuntimeError, "boom"
    end
  end

  describe "#to_permitted_param" do
    it "permits an array value" do
      expect(described_class.new(:addon_ids, options: []).to_permitted_param).to eq [{addon_ids: []}]
    end
  end

  describe "#fill_field" do
    let(:record_class) do
      Class.new do
        attr_accessor :addon_ids
      end
    end

    it "strips the hidden blank marker before assignment" do
      record = record_class.new
      field = described_class.new(:addon_ids, options: [])

      field.fill_field(record, :addon_ids, ["", "1", "3"], {})

      expect(record.addon_ids).to eq ["1", "3"]
    end

    it "assigns an empty array when every submitted value is blank" do
      record = record_class.new
      field = described_class.new(:addon_ids, options: [])

      field.fill_field(record, :addon_ids, [""], {})

      expect(record.addon_ids).to eq []
    end
  end

  describe "#normalize_id" do
    it "normalizes non-nil values to strings" do
      field = described_class.new(:addon_ids, options: [])

      expect(field.normalize_id(1)).to eq "1"
      expect(field.normalize_id("1")).to eq "1"
      expect(field.normalize_id(nil)).to be_nil
    end
  end

  describe "#inline_search?" do
    it "defaults to false" do
      field = described_class.new(:addon_ids, options: [])

      expect(field.inline_search?).to be false
    end

    it "is enabled with inline_search: true" do
      field = described_class.new(:addon_ids, options: [], inline_search: true)

      expect(field.inline_search?).to be true
    end
  end

  describe "option readers" do
    let(:field) { described_class.new(:addon_ids, options: []) }

    it "reads image urls from avatar_url or image_url keys" do
      expect(field.option_image_url({avatar_url: "/avatar.png"})).to eq "/avatar.png"
      expect(field.option_image_url({"avatar_url" => "/avatar.png"})).to eq "/avatar.png"
      expect(field.option_image_url({image_url: "/image.png"})).to eq "/image.png"
      expect(field.option_image_url({"image_url" => "/image.png"})).to eq "/image.png"
      expect(field.option_avatar_url({image_url: "/image.png"})).to eq "/image.png"
    end

    it "reads image format, image alt, and description keys" do
      expect(field.option_image_format({image_format: "rounded"})).to eq "rounded"
      expect(field.option_image_format({"image_format" => "square"})).to eq "square"
      expect(field.option_image_alt({image_alt: "User avatar"})).to eq "User avatar"
      expect(field.option_image_alt({"avatar_alt" => "User avatar"})).to eq "User avatar"
      expect(field.option_description({description: "Details"})).to eq "Details"
      expect(field.option_description({"description" => "Details"})).to eq "Details"
    end
  end

  describe "initialization" do
    it "requires options" do
      expect { described_class.new(:addon_ids) }
        .to raise_error ArgumentError, "Missing required `options:` keyword for checkbox_list field"
    end

    it "rejects nil options" do
      expect { described_class.new(:addon_ids, options: nil) }
        .to raise_error ArgumentError, "Missing required `options:` keyword for checkbox_list field"
    end

    it "is discovered by the field manager" do
      manager = Avo::Fields::FieldManager.build

      expect(Avo::Fields::BaseField.descendants).to include described_class
      expect(manager.all).to include hash_including(name: "checkbox_list", class: described_class)
    end
  end
end
