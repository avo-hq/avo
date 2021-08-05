require "rails_helper"

RSpec.describe "Filters", type: :system do
  describe "Boolean filter without default" do
    let!(:featured_post) { create :post, name: "Featured post", is_featured: true, published_at: nil }
    let!(:unfeatured_post) { create :post, name: "Unfeatured post", is_featured: false, published_at: nil }

    let(:url) { "/admin/resources/posts?view_type=table" }

    it "displays the filter" do
      visit url
      open_filters_menu

      expect(page).to have_text "Featured status"
      expect(page).to have_unchecked_field "Featured"
      expect(page).to have_unchecked_field "Unfeatured"
      expect(page).to have_text "Featured post"
      expect(page).to have_text "Unfeatured post"
      expect(page).to have_button("Reset filters", disabled: true)
    end

    it "changes the query" do
      visit url
      open_filters_menu

      check "Featured"
      wait_for_loaded
      open_filters_menu

      expect(page).to have_text "Featured post"
      expect(page).not_to have_text "Unfeatured post"
      expect(page).to have_checked_field "Featured"
      expect(page).to have_unchecked_field "Unfeatured"
      expect(current_url).to include "filters="
      expect(page).to have_link("Reset filters")
    end

    it "changes the query back also with reset" do
      visit url
      open_filters_menu

      check "Featured"
      wait_for_loaded
      open_filters_menu

      expect(page).to have_text "Featured post"
      expect(page).not_to have_text "Unfeatured post"
      expect(current_url).to include "filters="
      expect(page).to have_link("Reset filters")

      uncheck "Featured"
      wait_for_loaded
      open_filters_menu

      expect(page).to have_text "Featured post"
      expect(page).to have_text "Unfeatured post"
      expect(page).to have_unchecked_field "Featured"
      expect(page).to have_unchecked_field "Unfeatured"
      expect(page).to have_link("Reset filters")

      check "Featured"
      wait_for_loaded
      open_filters_menu
      check "Unfeatured"
      wait_for_loaded
      open_filters_menu

      expect(page).to have_text "Featured post"
      expect(page).to have_text "Unfeatured post"
      expect(page).to have_checked_field "Featured"
      expect(page).to have_checked_field "Unfeatured"
      expect(page).to have_link("Reset filters")

      click_on "Reset filters"
      wait_for_loaded
      open_filters_menu

      expect(page).to have_text "Featured post"
      expect(page).to have_text "Unfeatured post"
      expect(page).to have_unchecked_field "Featured"
      expect(page).to have_unchecked_field "Unfeatured"
      expect(current_url).not_to include "filters="
      expect(page).to have_button("Reset filters", disabled: true)
    end
  end

  describe "Boolean filter with default" do
    let!(:user) { create :user }

    let!(:team_without_members) { create :team, name: "Without Members" }
    let!(:team_with_members) { create :team, name: "With Members" }

    before do
      team_with_members.members << user
    end

    let(:url) { "/admin/resources/teams?view_type=table" }

    it "displays the filter" do
      visit url
      open_filters_menu

      expect(page).to have_text "Members filter"
      expect(page).to have_checked_field "Has Members"
      expect(page).not_to have_text "Without Members"
      expect(page).to have_text "With Members"
      expect(page).to have_button("Reset filters", disabled: true)
    end

    it "changes the query and reset" do
      visit url
      open_filters_menu

      uncheck "Has Members"
      wait_for_loaded
      open_filters_menu

      expect(page).to have_text "Members filter"
      expect(page).to have_unchecked_field "Has Members"
      expect(page).to have_text "Without Members"
      expect(page).to have_text "With Members"
      expect(page).to have_link("Reset filters")

      click_on "Reset filters"
      wait_for_loaded

      open_filters_menu

      expect(page).to have_text "Members filter"
      expect(page).to have_checked_field "Has Members"
      expect(page).not_to have_text "Without Members"
      expect(page).to have_text "With Members"
      expect(page).to have_button("Reset filters", disabled: true)
    end
  end

  describe "Select filter" do
    let!(:published_post) { create :post, name: "Published post", published_at: "2019-12-05 08:27:19.295065" }
    let!(:unpublished_post) { create :post, name: "Unpublished post", published_at: nil }

    let(:url) { "/admin/resources/posts?view_type=table" }

    context "without default value" do
      it "displays the filter" do
        visit url
        open_filters_menu

        expect(page).to have_text "Published status"
        expect(page).to have_select "published status", selected: empty_dash, options: [empty_dash, "Published", "Unpublished"]
        expect(page).to have_text "Published post"
        expect(page).to have_text "Unpublished post"
        expect(page).to have_button("Reset filters", disabled: true)
      end

      it "changes the query" do
        visit url
        open_filters_menu

        select "Published", from: "avo_filters_published_status"
        wait_for_loaded
        open_filters_menu

        expect(page).to have_text "Published post"
        expect(page).not_to have_text "Unpublished post"
        expect(page).to have_select "avo_filters_published_status", selected: "Published", options: [empty_dash, "Published", "Unpublished"]
        expect(current_url).to include "filters="
        expect(page).to have_link("Reset filters")
      end

      it "changes the query back also with reset" do
        visit url
        open_filters_menu

        select "Published", from: "avo_filters_published_status"
        wait_for_loaded
        open_filters_menu

        expect(page).to have_text "Published post"
        expect(page).not_to have_text "Unpublished post"
        expect(page).to have_select "avo_filters_published_status", selected: "Published", options: [empty_dash, "Published", "Unpublished"]
        expect(current_url).to include "filters="
        expect(page).to have_link("Reset filters")

        select empty_dash, from: "avo_filters_published_status"
        wait_for_loaded
        open_filters_menu

        expect(page).to have_text "Published post"
        expect(page).to have_text "Unpublished post"
        expect(page).to have_select "avo_filters_published_status", selected: empty_dash, options: [empty_dash, "Published", "Unpublished"]
        expect(current_url).not_to include "filters="
        expect(page).to have_button("Reset filters", disabled: true)

        select "Unpublished", from: "avo_filters_published_status"
        wait_for_loaded
        open_filters_menu

        expect(page).not_to have_text "Published post"
        expect(page).to have_text "Unpublished post"
        expect(page).to have_select "avo_filters_published_status", selected: "Unpublished", options: [empty_dash, "Published", "Unpublished"]
        expect(current_url).to include "filters="
        expect(page).to have_link("Reset filters")

        click_on "Reset filters"
        wait_for_loaded
        open_filters_menu

        expect(page).to have_text "Published status"
        expect(page).to have_select "avo_filters_published_status", selected: empty_dash, options: [empty_dash, "Published", "Unpublished"]
        expect(page).to have_text "Published post"
        expect(page).to have_text "Unpublished post"
        expect(page).to have_button("Reset filters", disabled: true)
      end
    end
  end

  describe "Multiple select filter" do
    let!(:draft) { create :post, name: "draft post", status: "draft" }
    let!(:published) { create :post, name: "draft post", status: "published" }
    let!(:archived) { create :post, name: "draft post", status: "archived" }

    let(:url) { "/admin/resources/posts?view_type=table" }

    context "without default value" do
      it "displays the filter" do
        visit url
        open_filters_menu

        expect(page).to have_text "Status"
        expect(page).to have_select "avo_filters_status", selected: ["draft", "published", "archived"], options: ["draft", "published", "archived"]
        expect(page).to have_button("Reset filters", disabled: true)
      end

      it "changes the query" do
        visit url
        open_filters_menu

        select "draft", from: "avo_filters_status"
        unselect "published", from: "avo_filters_status"
        unselect "archived", from: "avo_filters_status"
        click_on "Filter by Status"
        wait_for_loaded

        expect(page).to have_text("Displaying 1 item")

        open_filters_menu

        expect(page).to have_select "avo_filters_status", selected: ["draft"], options: ["draft", "published", "archived"]
        expect(current_url).to include "filters="
        expect(page).to have_link("Reset filters")
      end

      it "allows multiple selections" do
        visit url
        open_filters_menu

        select "draft", from: "avo_filters_status"
        select "published", from: "avo_filters_status"
        unselect "archived", from: "avo_filters_status"
        click_on "Filter by Status"
        wait_for_loaded

        expect(page).to have_text("Displaying 2 items")
      end
    end
  end

  describe "pagination resets when filters change" do
    let!(:published_posts) { create_list(:post, 40, published_at: rand((DateTime.now - 3.months)..DateTime.now)) }
    let!(:unpublished_post) { create :post, name: "Unpublished post", published_at: nil }
    let(:url) { "/admin/resources/posts?view_type=table&per_page=12" }

    context "with pagination set" do
      it "resets the pagination" do
        visit url
        click_on "3"
        wait_for_loaded
        click_on "Filters"
        wait_for_loaded
        check "Featured"

        expect(page).to have_css ".page.next"
        expect(page).to have_css ".page.active"
        expect(find(".page.active")).to have_text "1"
        expect(find(".page.active")).not_to have_text "2"
      end
    end
  end
end

def open_filters_menu
  find('[data-button="resource-filters"]').click
end
