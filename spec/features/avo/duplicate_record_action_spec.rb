require "rails_helper"

RSpec.describe "DuplicateRecord Action", type: :feature do
  # Simple test double that supports dup
  class DummyRecord
    attr_accessor :name, :title, :body, :slug, :status, :version

    def initialize(attrs = {})
      attrs.each { |k, v| send(:"#{k}=", v) if respond_to?(:"#{k}=") }
    end

    def dup
      self.class.new(
        name: name,
        title: title,
        body: body,
        slug: slug,
        status: status,
        version: version
      )
    end
  end

  describe "duplicate_record" do
    let(:action) { Avo::Actions::DuplicateRecord.new }

    it "duplicates a simple record with excluded fields" do
      original = DummyRecord.new(
        name: "Original Post",
        body: "Content here",
        slug: "original-post"
      )

      config = { exclude: [:slug], title_field: :name }
      duplicated = action.send(:duplicate_record, original, config)

      expect(duplicated.name).to eq("Original Post Copy")
      expect(duplicated.body).to eq("Content here")
      expect(duplicated.slug).to be_nil
    end

    it "uses custom title suffix" do
      original = DummyRecord.new(name: "Test")

      config = { title_field: :name, title_suffix: " (duplicate)" }
      duplicated = action.send(:duplicate_record, original, config)

      expect(duplicated.name).to eq("Test (duplicate)")
    end

    it "applies default values" do
      original = DummyRecord.new(name: "Test", status: "published")

      config = {
        title_field: :name,
        defaults: { status: "draft" }
      }
      duplicated = action.send(:duplicate_record, original, config)

      expect(duplicated.name).to eq("Test Copy")
      expect(duplicated.status).to eq("draft")
    end

    it "applies callable defaults" do
      original = DummyRecord.new(name: "Test", version: 5)

      config = {
        title_field: :name,
        defaults: { version: ->(r) { r.version + 1 } }
      }
      duplicated = action.send(:duplicate_record, original, config)

      expect(duplicated.version).to eq(6)
    end

    it "auto-detects title field from common names" do
      original = DummyRecord.new(title: "My Title", body: "Content")

      config = {}
      duplicated = action.send(:duplicate_record, original, config)

      expect(duplicated.title).to eq("My Title Copy")
    end

    it "handles missing title field gracefully" do
      original = DummyRecord.new(body: "Just body, no title")

      config = {}
      duplicated = action.send(:duplicate_record, original, config)

      expect(duplicated.body).to eq("Just body, no title")
    end
  end

  describe "with Product model" do
    let(:action) { Avo::Actions::DuplicateRecord.new }

    it "duplicates a Product record" do
      product = create(:product, title: "Original Product", description: "Test description", price_cents: 9999)

      config = { title_field: :title }
      duplicated = action.send(:duplicate_record, product, config)

      expect(duplicated).to be_a(Product)
      expect(duplicated.title).to eq("Original Product Copy")
      expect(duplicated.description).to eq("Test description")
      expect(duplicated.price_cents).to eq(9999)
      expect(duplicated.id).to be_nil
    end

    it "saves duplicated Product to database" do
      product = create(:product, title: "Saveable Product", price_cents: 5000)

      config = { title_field: :title }
      duplicated = action.send(:duplicate_record, product, config)
      duplicated.save!

      expect(duplicated).to be_persisted
      expect(duplicated.id).not_to eq(product.id)
      expect(Product.where(title: "Saveable Product Copy").count).to eq(1)
    end
  end
end
