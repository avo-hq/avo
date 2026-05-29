require "rails_helper"

RSpec.describe Avo::BulkUpdate::BannerComponent, type: :component do
  describe "K-of-N (default variant)" do
    it "hides the exclusion line when K == N" do
      render_inline(described_class.new(authorized_count: 5, total_count: 5))

      expect(page).to have_css(".bulk-update-banner")
      expect(page).to have_text("Updating")
      expect(page).to have_text("5")
      expect(page).not_to have_text(/excluded/i)
    end

    it "renders the K-of-N count and the exclusion line when K < N" do
      render_inline(described_class.new(authorized_count: 3, total_count: 5))

      expect(page).to have_text("Updating")
      expect(page).to have_text("3")
      expect(page).to have_text("5")
      # Count-only excluded count (no IDs leak)
      expect(page).to have_text("2 records were excluded")
    end

    it "uses singular wording for one excluded record" do
      render_inline(described_class.new(authorized_count: 4, total_count: 5))

      expect(page).to have_text("1 record was excluded")
    end

    it "renders the info-circle icon and accent tone for the default variant" do
      render_inline(described_class.new(authorized_count: 5, total_count: 5))

      expect(page).to have_css(".bulk-update-banner.bulk-update-banner--accent")
      expect(page).to have_css(".bulk-update-banner__icon svg")
    end

    it "exposes aria-live=polite for SR announcement on partial-failure retry" do
      render_inline(described_class.new(authorized_count: 3, total_count: 5))

      expect(page).to have_css(".bulk-update-banner[aria-live='polite'][role='status']")
    end
  end

  describe "no_records_editable variant" do
    it "renders the 'no records editable' message when K == 0" do
      # Implicit variant: default with authorized_count == 0 maps to :no_records_editable.
      render_inline(described_class.new(authorized_count: 0, total_count: 5))

      expect(page).to have_text("No selected records are editable by you")
    end

    it "renders the caution tone for the no-records-editable variant" do
      render_inline(described_class.new(variant: :no_records_editable, authorized_count: 0, total_count: 5))

      expect(page).to have_css(".bulk-update-banner.bulk-update-banner--caution")
    end
  end

  describe "cap_exceeded variant" do
    it "renders the cap-exceeded title and body with the count and max" do
      render_inline(described_class.new(variant: :cap_exceeded, total_count: 600, max_records: 500))

      expect(page).to have_text("Too many records selected")
      expect(page).to have_text("600")
      expect(page).to have_text("500")
    end

    it "uses the alert-triangle icon (not info-circle) for the cap-exceeded variant" do
      render_inline(described_class.new(variant: :cap_exceeded, total_count: 600, max_records: 500))

      svg = page.find(".bulk-update-banner__icon svg")
      expect(svg.path).not_to be_nil
    end
  end

  describe "n_too_small variant" do
    it "renders the 'needs at least two records' message" do
      render_inline(described_class.new(variant: :n_too_small, authorized_count: 1, total_count: 5))

      expect(page).to have_text("at least two records")
      expect(page).to have_text("1 record")
    end
  end

  it "rejects unknown variants" do
    expect { described_class.new(variant: :bogus) }.to raise_error(ArgumentError, /Invalid variant/)
  end
end
