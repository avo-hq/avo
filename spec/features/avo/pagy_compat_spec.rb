require "rails_helper"

RSpec.describe Avo::PagyCompat do
  describe ".slots" do
    it "keeps an Integer size" do
      expect(described_class.slots(9)).to eq 9
    end

    # Pagy 9 renders [1, 2, 2, 1] as 1, gap, two pages, the current page, two pages, gap, last page.
    it "gives an Array size of pagy 7 the slots for the same links" do
      expect(described_class.slots([1, 2, 2, 1])).to eq 9
    end

    it "keeps an empty Array as no page links" do
      expect(described_class.slots([])).to eq 0
    end
  end
end
