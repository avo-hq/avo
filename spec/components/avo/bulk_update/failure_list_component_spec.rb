require "rails_helper"

RSpec.describe Avo::BulkUpdate::FailureListComponent, type: :component do
  describe "header" do
    it "renders role='alert' so SRs announce assertively on partial failure" do
      render_inline(described_class.new(failed: [{id: 1, reason: :validation, message: "Name is too short"}]))

      expect(page).to have_css(".bulk-update-failure-list[role='alert']")
    end

    it "renders the accent (caution) panel tone" do
      render_inline(described_class.new(failed: [{id: 1, reason: :validation}]))

      expect(page).to have_css(".bulk-update-failure-list--caution")
    end

    it "renders the heading icon and heading count" do
      render_inline(described_class.new(failed: [
        {id: 1, reason: :validation},
        {id: 2, reason: :validation}
      ]))

      expect(page).to have_css(".bulk-update-failure-list__heading-icon svg")
      expect(page).to have_text("2 records could not be updated")
    end

    it "uses the singular heading when exactly one record failed" do
      render_inline(described_class.new(failed: [{id: 1, reason: :validation}]))

      expect(page).to have_text("1 record could not be updated")
    end
  end

  describe "reason chips" do
    it "uses the lock-x icon and 'Not allowed' label for :unauthorized_at_write" do
      render_inline(described_class.new(failed: [{id: 1, reason: :unauthorized_at_write}]))

      expect(page).to have_css(".bulk-update-failure-list__chip--unauthorized_at_write")
      expect(page).to have_text("Not allowed")
    end

    it "uses the alert-circle icon and 'Validation failed' label for :validation" do
      render_inline(described_class.new(failed: [{id: 1, reason: :validation}]))

      expect(page).to have_css(".bulk-update-failure-list__chip--validation")
      expect(page).to have_text("Validation failed")
    end

    it "uses the refresh-alert icon and 'Record changed elsewhere' label for :concurrent_modification" do
      render_inline(described_class.new(failed: [{id: 1, reason: :concurrent_modification}]))

      expect(page).to have_css(".bulk-update-failure-list__chip--concurrent_modification")
      expect(page).to have_text("Record changed elsewhere")
    end

    it "humanizes unknown reasons from custom overrides" do
      render_inline(described_class.new(failed: [{id: 1, reason: :custom_business_rule}]))

      # Custom reasons fall through the localized key with the reason
      # interpolated; the chip CSS modifier uses the raw key.
      expect(page).to have_css(".bulk-update-failure-list__chip--custom_business_rule")
      expect(page).to have_text(/Custom business rule/i)
    end
  end

  describe "messages" do
    it "displays the user-facing message truncated to one visible line" do
      long = "Name is too short. " * 30
      render_inline(described_class.new(failed: [{id: 1, reason: :validation, message: long}]))

      expect(page).to have_css(".bulk-update-failure-list__message")
      # Tooltip carries the full text.
      expect(page).to have_css(".bulk-update-failure-list__message[title]")
    end

    it "omits the message span entirely when no message was provided" do
      render_inline(described_class.new(failed: [{id: 1, reason: :unauthorized_at_write}]))

      expect(page).not_to have_css(".bulk-update-failure-list__message")
    end
  end

  describe "retry button" do
    it "carries the comma-joined failed IDs in a data attribute for the form Stimulus controller" do
      render_inline(described_class.new(failed: [
        {id: 1, reason: :validation, message: "x"},
        {id: 7, reason: :unauthorized_at_write}
      ]))

      retry_button = page.find(".bulk-update-failure-list__retry")
      expect(retry_button["data-retry-failed-ids"]).to eq("1,7")
      expect(retry_button["data-action"]).to include("click->bulk-update-form#retryFailed")
    end

    it "renders the retry localized copy" do
      render_inline(described_class.new(failed: [{id: 1, reason: :validation}]))

      expect(page).to have_text("Retry failed")
    end
  end

  describe "empty list" do
    it "still renders the structural shell when failed is empty (defensive)" do
      render_inline(described_class.new(failed: []))

      expect(page).to have_css(".bulk-update-failure-list")
    end
  end
end
