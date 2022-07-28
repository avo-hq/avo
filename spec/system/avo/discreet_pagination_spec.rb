require "rails_helper"

RSpec.describe "DiscreetPagination", type: :system do
  let!(:per_page) { Avo.configuration.via_per_page }
  
  context 'has_many_field' do
    let!(:one_page_of_links) { create_list :course_link, per_page }
    let!(:two_pages_of_links) { create_list :course_link, per_page * 2 }
    let!(:course_with_one_page_of_links) { create :course, links: one_page_of_links }
    let!(:course_with_two_pages_of_links) { create :course, links: two_pages_of_links }

    describe "with one page" do
      it "should not have pagination" do
        visit "/admin/resources/courses/#{course_with_one_page_of_links.id}"
        wait_for_loaded

        expect(page).to have_text "Links"
        expect(page).not_to have_text "Displaying #{per_page} items"
      end
    end
  
    describe "with two pages" do
      it "should have pagination" do
        visit "/admin/resources/courses/#{course_with_two_pages_of_links.id}"
        wait_for_loaded

        expect(page).to have_text "Links"
        expect(page).to have_text "Displaying items 1-#{per_page} of #{per_page * 2} in total"
      end
    end
  end
end
