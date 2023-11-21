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
        saved_value = Avo.configuration.cache_resource_filters
        Avo.configuration.cache_resource_filters = lambda {
          true
        }
        it.run
        Avo.configuration.cache_resource_filters = saved_value
      end

      it "persist filters by name" do
        visit url
        expect(page).to have_text("Displaying 2 item")

        open_filters_menu
        fill_in "avo_filters_name_filter", with: "With Members"
        click_on "Filter by name"
        wait_for_loaded
        expect(page).to have_text("Displaying 1 item")

        visit url
        expect(page).to have_text("Displaying 1 item")

        open_filters_menu
        expect(page).to have_text "With Members"
        expect(page).to have_link("Reset filters")

        click_on "Reset filters"
        wait_for_loaded
        expect(page).to have_text("Displaying 2 item")

        visit url
        expect(page).to have_text("Displaying 2 item")
      end
    end

    context "cache resource filter disabled" do
      around(:each) do |it|
        saved_value = Avo.configuration.cache_resource_filters
        Avo.configuration.cache_resource_filters = false
        it.run
        Avo.configuration.cache_resource_filters = saved_value
      end

      it "doesn't persist filters by name" do
        visit url
        expect(page).to have_text("Displaying 2 item")

        open_filters_menu
        fill_in "avo_filters_name_filter", with: "With Members"
        click_on "Filter by name"
        wait_for_loaded
        expect(page).to have_text("Displaying 1 item")

        visit url
        expect(page).to have_text("Displaying 2 item")
      end
    end
  end
end
