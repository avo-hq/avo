require "rails_helper"

RSpec.feature "discreet_information", type: :system do
  # Test data setup
  let!(:product) { create(:product) }
  let!(:post) { create(:post, published_at: Time.now - rand(10...365).days) }
  let!(:event) { create(:event) }

  # Common helper methods
  let(:time_format) { "%Y-%m-%d %H:%M:%S" }

  def formatted_timestamps(record)
    {
      created_at: record.created_at.strftime(time_format),
      updated_at: record.updated_at.strftime(time_format)
    }
  end

  def expect_timestamps_tooltip(record)
    timestamps = formatted_timestamps(record)
    expect(page).to have_selector(
      "div[has-data-tippy='<div style=\"text-align: right;\">Created at #{timestamps[:created_at]}<br>Updated at #{timestamps[:updated_at]}</div>']",
      visible: true
    ) do |div|
      expect(div).to have_selector("svg[class='text-2xl h-4']")
    end
  end

  describe "discreet information display" do
    context "when viewing a product" do
      before { visit avo.resources_product_path(product) }

      it "shows product status tooltip" do
        expect(page).to have_selector(
          "div[has-data-tippy='Product is <strong>#{product.status}</strong>']",
          visible: true
        ) do |div|
          expect(div).to have_selector("svg[class='text-2xl h-4']")
        end
      end

      it "shows timestamps tooltip" do
        expect_timestamps_tooltip(product)
      end
    end

    context "when viewing a post" do
      before { visit avo.resources_post_path(post) }

      it "shows publication status tooltip" do
        expect(page).to have_selector(
          "div[has-data-tippy='Product is <strong>#{post.published_at ? "published" : "draft"}</strong>']",
          visible: true
        ) do |div|
          expect(div).to have_selector("svg[class='text-2xl h-4']")
        end
      end

      it "shows timestamps tooltip" do
        expect_timestamps_tooltip(post)
      end

      it "allows toggling publication status" do
        # Check initial published state
        expect(page).to have_selector(
          "a[has-data-tippy='Post is published. Click to toggle.']",
          visible: true
        ) do |link|
          expect(link).to have_content("✅")
        end

        # Toggle publication status
        find("a[has-data-tippy='Post is published. Click to toggle.']").click

        # Verify changed state
        expect(page).to have_selector(
          "a[has-data-tippy='Post is draft. Click to toggle.']",
          visible: true
        ) do |link|
          expect(link).to have_content("🙄")
        end
      end
    end

    context "when viewing an event" do
      before { visit avo.resources_event_path(event) }

      it "shows timestamps tooltip" do
        expect_timestamps_tooltip(event)
      end
    end
  end
end
