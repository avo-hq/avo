require "rails_helper"

RSpec.describe Avo::BulkUpdate::StatusNoticeComponent, type: :component do
  let(:field) { Struct.new(:id, :name, keyword_init: true).new(id: :stage, name: "Stage") }

  describe "all_share mode" do
    it "renders 'All N records have <field> set to <value>'" do
      render_inline(described_class.new(
        field: field,
        notice: {mode: :all_share, value: "success", count: 47}
      ))

      expect(page).to have_text("All")
      expect(page).to have_text("47")
      expect(page).to have_text("Stage")
      expect(page).to have_text("success")
    end

    it "applies the muted-neutral tone class" do
      render_inline(described_class.new(
        field: field,
        notice: {mode: :all_share, value: "success", count: 5}
      ))

      expect(page).to have_css(".bulk-update-status-notice.bulk-update-status-notice--muted")
    end

    it "renders a localized 'blank' label when the shared value is nil/empty" do
      render_inline(described_class.new(
        field: field,
        notice: {mode: :all_share, value: nil, count: 5}
      ))

      expect(page).to have_text("blank")
    end

    it "exposes a stable notice id so a field input can aria-describedby it" do
      render_inline(described_class.new(
        field: field,
        notice: {mode: :all_share, value: "success", count: 5}
      ))

      expect(page).to have_css("#bulk-update-status-notice-stage")
    end
  end

  describe "sample_list mode" do
    it "lists the distinct sample values comma-separated" do
      render_inline(described_class.new(
        field: field,
        notice: {
          mode: :sample_list,
          values: ["success", "in_progress", "blocked"],
          distinct_count: 3,
          count: 8
        }
      ))

      expect(page).to have_text("3 different values")
      expect(page).to have_text("success, in_progress, blocked")
    end

    it "applies the tertiary tone class" do
      render_inline(described_class.new(
        field: field,
        notice: {
          mode: :sample_list,
          values: ["a", "b"],
          distinct_count: 2,
          count: 8
        }
      ))

      expect(page).to have_css(".bulk-update-status-notice.bulk-update-status-notice--tertiary")
    end
  end

  describe "count_only mode" do
    it "renders 'N different values' without listing them (threshold exceeded)" do
      render_inline(described_class.new(
        field: field,
        notice: {mode: :count_only, distinct_count: 12, count: 47}
      ))

      expect(page).to have_text("12 different values")
      expect(page).not_to have_text(":")
    end

    it "applies the accent (caution-flavored) tone class" do
      render_inline(described_class.new(
        field: field,
        notice: {mode: :count_only, distinct_count: 12, count: 47}
      ))

      expect(page).to have_css(".bulk-update-status-notice.bulk-update-status-notice--accent")
    end
  end

  it "rejects unknown modes" do
    expect {
      described_class.new(
        field: field,
        notice: {mode: :bogus, count: 1}
      )
    }.to raise_error(ArgumentError, /Invalid notice mode/)
  end
end
