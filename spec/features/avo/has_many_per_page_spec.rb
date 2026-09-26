require "rails_helper"

RSpec.describe "HasManyPerPage", type: :feature do
  context "when the field sets per_page" do
    let!(:fish) { create :fish }
    let!(:reviews) { create_list :review, 5, reviewable: fish }

    it "shows that many records per page" do
      visit "/admin/resources/fish/#{fish.id}/reviews?turbo_frame=has_many_field_show_reviews"
      wait_for_loaded

      expect(page).to have_css "tr[data-record-id]", count: 3
      expect(page).to have_css ".pagination__info-number", text: "1-3"
      expect(page).to have_css ".dropdown-menu__item .pagination__per-page-option-num", exact_text: "3"
    end

    it "lets the per_page param override it" do
      visit "/admin/resources/fish/#{fish.id}/reviews?turbo_frame=has_many_field_show_reviews&per_page=4"
      wait_for_loaded

      expect(page).to have_css "tr[data-record-id]", count: 4
      expect(page).to have_css ".pagination__info-number", text: "1-4"
      expect(page).to have_css ".dropdown-menu__item .pagination__per-page-option-num", exact_text: "3"
    end

    context "with session persistence" do
      around do |example|
        Avo.configuration.persistence = {driver: :session}
        example.run
      ensure
        Avo.configuration.persistence = {driver: nil}
      end

      it "prefers the persisted per_page over it" do
        visit "/admin/resources/fish/#{fish.id}/reviews?turbo_frame=has_many_field_show_reviews&per_page=4"
        visit "/admin/resources/fish/#{fish.id}/reviews?turbo_frame=has_many_field_show_reviews"
        wait_for_loaded

        expect(page).to have_css "tr[data-record-id]", count: 4
      end
    end
  end

  context "when the field does not set per_page" do
    let!(:per_page) { Avo.configuration.via_per_page }
    let!(:person) { create :person, spouses: create_list(:spouse, per_page + 1) }

    it "falls back to via_per_page" do
      visit "/admin/resources/people/#{person.id}/spouses?turbo_frame=has_many_field_show_spouses"
      wait_for_loaded

      expect(page).to have_css "tr[data-record-id]", count: per_page
      expect(page).to have_css ".pagination__info-number", text: "1-#{per_page}"
    end
  end
end
