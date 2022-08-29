require "rails_helper"

RSpec.describe 'DiscreetPagination', type: :feature do
  let!(:per_page) { Avo.configuration.via_per_page }

  context 'has_many_field' do
    context 'discreet_pagination=true' do
      let!(:one_page_of_links) { create_list :course_link, per_page }
      let!(:two_pages_of_links) { create_list :course_link, per_page * 2 }
      let!(:course_with_one_page_of_links) { create :course, links: one_page_of_links }
      let!(:course_with_two_pages_of_links) { create :course, links: two_pages_of_links }

      describe 'with one page' do
        it 'should not have pagination' do
          visit "/admin/resources/courses/#{course_with_one_page_of_links.id}/links?turbo_frame=has_many_field_show_links"
          wait_for_loaded

          expect(current_path).to eql "/admin/resources/courses/#{course_with_one_page_of_links.id}/links"
          expect(page).not_to have_text "Displaying #{per_page} items"
        end
      end
      
      describe 'with two pages' do
        it 'should have pagination' do
          visit "/admin/resources/courses/#{course_with_two_pages_of_links.id}/links?turbo_frame=has_many_field_show_links"
          wait_for_loaded
          
          expect(current_path).to eql "/admin/resources/courses/#{course_with_two_pages_of_links.id}/links"
          expect(page).to have_text "Displaying items 1-#{per_page} of #{per_page * 2} in total"
        end
      end
    end

    context 'discreet_pagination=false' do
      let!(:one_page_of_spouses) { create_list :spouse, per_page }
      let!(:two_pages_of_spouses) { create_list :spouse, per_page * 2 }
      let!(:person_with_one_page_of_spouses) { create :person, spouses: one_page_of_spouses }
      let!(:person_with_two_pages_of_spouses) { create :person, spouses: two_pages_of_spouses}

      describe 'with one page' do
        it 'should have pagination' do
          visit "/admin/resources/people/#{person_with_one_page_of_spouses.id}/spouses?turbo_frame=has_many_field_show_spouses"
          wait_for_loaded

          expect(current_path).to eql "/admin/resources/people/#{person_with_one_page_of_spouses.id}/spouses"
          expect(page).to have_text "Displaying #{per_page} items"
        end
      end
      
      describe 'with two pages' do
        it 'should have pagination' do
          visit "/admin/resources/people/#{person_with_two_pages_of_spouses.id}/spouses?turbo_frame=has_many_field_show_spouses"
          wait_for_loaded
          
          expect(current_path).to eql "/admin/resources/people/#{person_with_two_pages_of_spouses.id}/spouses"
          expect(page).to have_text "Displaying items 1-#{per_page} of #{per_page * 2} in total"
        end
      end
    end
  end
end
