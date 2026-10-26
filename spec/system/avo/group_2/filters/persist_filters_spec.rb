# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Persist Filters", type: :system do
  describe "With Text filter" do
    let!(:user) { create :user }

    let!(:team_without_members) { create :team, name: "Without Members" }
    let!(:team_with_members) { create :team, name: "With Members" }

    before do
      team_with_members.team_members << user
      team_without_members.team_members << user
    end

    let(:url) { "/admin/resources/teams?view_type=table" }

    context "cache resource filter enabled" do
      around(:each) do |it|
        Avo.configuration.persistence = {driver: :session}
        it.run
        Avo.configuration.persistence = {driver: nil}
      end

      it "persist filters by name" do
        visit url
        expect(page).to have_text("2 records")

        open_filters_menu
        fill_in "avo_filters_name_filter", with: "With Members"
        click_on "Filter by name"
        wait_for_loaded
        expect(page).to have_text("1 record")

        visit url
        expect(page).to have_text("1 record")

        open_filters_menu
        expect(page).to have_text "With Members"
        expect(page).to have_link("Reset filters")

        click_on "Reset filters"
        wait_for_loaded
        expect(page).to have_text("2 records")

        visit url
        expect(page).to have_text("2 records")
      end
    end

    context "cache resource filter disabled" do
      it "doesn't persist filters by name" do
        visit url
        expect(page).to have_text("2 records")

        open_filters_menu
        fill_in "avo_filters_name_filter", with: "With Members"
        click_on "Filter by name"
        wait_for_loaded
        expect(page).to have_text("1 record")

        visit url
        expect(page).to have_text("2 records")
      end
    end
  end

  describe "With Select filter" do
    let!(:published_post) { create :post, name: "Published post", published_at: "2019-12-05 08:27:19.295065" }
    let!(:unpublished_post) { create :post, name: "Unpublished post", published_at: nil }

    let(:url) { "/admin/resources/posts?view_type=table" }

    context "cache resource filter enabled" do
      around(:each) do |it|
        Avo.configuration.persistence = {driver: :session}
        it.run
        Avo.configuration.persistence = {driver: nil}
      end

      it "clears the persisted filter when the last filter is emptied" do
        visit url
        expect(page).to have_text "Published post"
        expect(page).to have_text "Unpublished post"

        open_filters_menu
        select "Published", from: "avo_filters_published_status"
        wait_for_loaded
        expect(page).to have_text "Published post"
        expect(page).not_to have_text "Unpublished post"

        visit url
        expect(page).to have_text "Published post"
        expect(page).not_to have_text "Unpublished post"

        open_filters_menu
        select "Published or unpublished", from: "avo_filters_published_status"
        wait_for_loaded
        expect(page).to have_text "Published post"
        expect(page).to have_text "Unpublished post"

        visit url
        expect(page).to have_text "Published post"
        expect(page).to have_text "Unpublished post"
      end
    end
  end
end
