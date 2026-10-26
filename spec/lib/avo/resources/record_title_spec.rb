require "rails_helper"

RSpec.describe "Resource#record_title" do
  # A record shaped like the ones titles are read off: it answers the fallback chain and
  # has an id. A Struct stands in so the test does not depend on a dummy model's columns.
  let(:record) do
    Struct.new(:name, :title, :label, :id) do
      def to_param = id.to_s
    end.new("Ada", "Countess", "Analyst", 7)
  end

  def resource_with(title:)
    Avo::Resources::Post.new(record: record).tap { |resource| resource.title = title }
  end

  describe "the existing behavior, unchanged" do
    it "prefers name from the fallback chain when no title is configured" do
      expect(resource_with(title: nil).record_title).to eq "Ada"
    end

    it "falls through the chain on a blank earlier candidate" do
      record.name = nil

      expect(resource_with(title: nil).record_title).to eq "Countess"
    end

    it "falls back to the param when the whole chain is empty" do
      record.name = nil
      record.title = nil
      record.label = nil

      expect(resource_with(title: nil).record_title).to eq "7"
    end

    it "reads a symbol title off the record" do
      expect(resource_with(title: :label).record_title).to eq "Analyst"
    end

    it "executes a proc title" do
      expect(resource_with(title: -> { "computed" }).record_title).to eq "computed"
    end

    # The shape belongs_to lookup lists and the association picker build once per option:
    # a bare resource whose fields were never detected. Its holder is empty rather than
    # absent, so a field-derived title would resolve against nothing and silently return
    # an id — every dropdown label collapsing at once, with no error to notice.
    it "returns a real title on a resource whose fields were never detected" do
      resource = Avo::Resources::Post.new(record: record)

      expect(resource.items_holder.items).to be_empty
      expect(resource.record_title).to eq "Ada"
    end
  end

  describe "the reachability seam" do
    # Core always answers true. A plugin that restricts what a user may reach overrides
    # this, which is what keeps a restricted attribute out of search results, breadcrumbs,
    # record links and the association picker without teaching each of them separately.
    it "answers true for any attribute by default" do
      expect(resource_with(title: nil).title_attribute_reachable?(:name)).to be(true)
    end

    it "skips an unreachable candidate and continues down the chain" do
      resource = resource_with(title: nil)
      allow(resource).to receive(:title_attribute_reachable?).and_return(true)
      allow(resource).to receive(:title_attribute_reachable?).with(:name).and_return(false)

      expect(resource.record_title).to eq "Countess"
    end

    it "falls back to the param when every candidate is unreachable" do
      resource = resource_with(title: nil)
      allow(resource).to receive(:title_attribute_reachable?).and_return(false)

      expect(resource.record_title).to eq "7"
    end

    it "falls back to the param when a symbol title names an unreachable attribute" do
      resource = resource_with(title: :label)
      allow(resource).to receive(:title_attribute_reachable?).with(:label).and_return(false)

      expect(resource.record_title).to eq "7"
    end

    # A proc title is app-authored code. The bounded promise puts the app's own code
    # outside this feature, so the seam is not consulted for it.
    it "is not consulted for a proc title" do
      resource = resource_with(title: -> { "computed" })
      allow(resource).to receive(:title_attribute_reachable?).and_return(false)

      expect(resource.record_title).to eq "computed"
    end
  end
end
