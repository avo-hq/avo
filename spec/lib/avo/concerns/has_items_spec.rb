require "rails_helper"

RSpec.describe Avo::Concerns::HasItems do
  after { Avo::Resources::Person.restore_items_from_backup }

  let(:visible) { create :person, name: "Visible" }
  let(:hidden) { create :person, name: "Hidden" }

  def ids(resource) = resource.visible_items.map(&:id)

  describe "memoization" do
    before do
      Avo::Resources::Person.with_temporary_items do
        field :name, as: :text
        field :only_when_visible, as: :text, visible: -> { resource.record&.name == "Visible" }
        field :only_on_show, as: :text, only_on: :show
      end
    end

    it "returns the same items without recomputing them" do
      resource = Avo::Resources::Person.new(view: :show, record: visible).detect_fields

      expect(ids(resource)).to eq [:name, :only_when_visible, :only_on_show]
      expect(resource.visible_items).to equal resource.visible_items
    end

    # BaseController#index builds each row as `@resource.dup`, and `dup` is shallow.
    it "gives each dup its own visibility even if the prototype was asked first" do
      prototype = Avo::Resources::Person.new(view: :show).detect_fields
      prototype.visible_items

      rows = [visible, hidden].map { |record| prototype.dup.hydrate(record: record) }

      expect(rows.map { |row| ids(row) }).to eq [
        [:name, :only_when_visible, :only_on_show],
        [:name, :only_on_show]
      ]
    end

    it "recomputes when the items are re-hydrated with another record" do
      resource = Avo::Resources::Person.new(view: :show, record: visible).detect_fields
      expect(ids(resource)).to include :only_when_visible

      resource.hydrate(record: hidden)

      expect(ids(resource)).not_to include :only_when_visible
    end

    it "recomputes when the view changes" do
      resource = Avo::Resources::Person.new(view: :show, record: visible).detect_fields
      expect(ids(resource)).to include :only_on_show

      resource.hydrate(view: :edit)

      expect(ids(resource)).not_to include :only_on_show
    end

    # BaseController#show calls `detect_fields` a second time, after hydrating.
    it "recomputes when detect_fields replaces the items" do
      resource = Avo::Resources::Person.new(view: :show, record: visible).detect_fields
      expect(ids(resource)).to include :name

      Avo::Resources::Person.with_temporary_items { field :replaced, as: :text }
      resource.detect_fields

      expect(ids(resource)).to eq [:replaced]
    end
  end
end
