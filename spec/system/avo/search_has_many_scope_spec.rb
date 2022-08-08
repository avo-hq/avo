# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Search with has_many attached scope', type: :system do
  let(:base_url) { '/admin/resources/courses' }
  let!(:five_links) { create_list :course_link, 5 }
  let!(:three_links) { create_list :course_link, 3 }
  let!(:course_with_five_links) { create :course, links: five_links }
  let!(:course_with_three_links) { create :course, links: three_links }
  let!(:course_without_links) { create :course }

  describe 'find records only from parent' do
    context "when searching from parent's association frame" do
      it 'opens the search' do
        visit "#{base_url}/#{course_without_links.id}/links?turbo_frame=has_many_field_show_links"

        find('.resource-search').click

        expect_search_panel_open
      end
    end

    context "when parent don't have any record associated" do
      it 'find zero records' do
        visit "#{base_url}/#{course_without_links.id}/links?turbo_frame=has_many_field_show_links"
        find('.resource-search').click
        expect_search_panel_open

        expect(page).to have_content 'Course links'

        all_course_links = five_links + three_links
        all_course_links.each do |course_link|
          write_in_search course_link.link

          expect(page).to have_content 'No course links found'
        end
      end
    end

    context 'when parent have three associated records' do
      it 'find only his three records' do
        visit "#{base_url}/#{course_with_three_links.id}/links?turbo_frame=has_many_field_show_links"
        find('.resource-search').click
        expect_search_panel_open

        expect(page).to have_content 'Course links'

        course_with_three_links.links.each do |course_link|
          write_in_search course_link.link

          expect(page).not_to have_content 'No course links found'
          expect(page).to have_content course_link.link
        end

        course_with_five_links.links.each do |course_link|
          write_in_search course_link.link

          expect(page).to have_content 'No course links found'
          expect(page).not_to have_content course_link.link
        end
      end
    end

    context 'when parent have five associated records' do
      it 'find only his five records' do
        visit "#{base_url}/#{course_with_five_links.id}/links?turbo_frame=has_many_field_show_links"
        find('.resource-search').click
        expect_search_panel_open

        expect(page).to have_content 'Course links'

        course_with_three_links.links.each do |course_link|
          write_in_search course_link.link

          expect(page).to have_content 'No course links found'
          expect(page).not_to have_content course_link.link
        end

        course_with_five_links.links.each do |course_link|
          write_in_search course_link.link

          expect(page).not_to have_content 'No course links found'
          expect(page).to have_content course_link.link
        end
      end
    end
  end
end

def expect_search_panel_open
  expect(page).to have_css '.aa-InputWrapper .aa-Input'
  expect(page).to have_selector('.aa-Input:focus')
end
