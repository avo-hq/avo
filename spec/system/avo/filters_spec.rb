require 'rails_helper'

RSpec.describe 'Filters', type: :system do
  let!(:featured_post) { create :post, name: 'Featured post', is_featured: true }
  let!(:unfeatured_post) { create :post, name: 'Unfeatured post', is_featured: false }

  describe 'Boolean filter' do
    let(:url) { '/avo/resources/posts' }

    it 'displays the filter' do
      visit url
      find('[data-button="resource-filters"]').click

      expect(page).to have_text 'Featured status'
      expect(page).to have_unchecked_field 'Featured'
      expect(page).to have_unchecked_field 'Unfeatured'
      expect(page).to have_text 'Featured post'
      expect(page).to have_text 'Unfeatured post'
    end

    it 'changes the query' do
      visit url
      find('[data-button="resource-filters"]').click

      check 'Featured'
      wait_for_loaded

      expect(page).to have_text 'Featured post'
      expect(page).not_to have_text 'Unfeatured post'
      expect(page).to have_checked_field 'Featured'
      expect(page).to have_unchecked_field 'Unfeatured'
      expect(current_url).to include 'filters='
    end

    it 'changes the query back' do
      visit url
      find('[data-button="resource-filters"]').click

      check 'Featured'
      wait_for_loaded

      expect(page).to have_text 'Featured post'
      expect(page).not_to have_text 'Unfeatured post'
      expect(current_url).to include 'filters='

      uncheck 'Featured'
      wait_for_loaded

      expect(page).to have_text 'Featured post'
      expect(page).to have_text 'Unfeatured post'
      expect(page).to have_unchecked_field 'Featured'
      expect(page).to have_unchecked_field 'Unfeatured'

      check 'Featured'
      check 'Unfeatured'

      expect(page).to have_text 'Featured post'
      expect(page).to have_text 'Unfeatured post'
      expect(page).to have_checked_field 'Featured'
      expect(page).to have_checked_field 'Unfeatured'
    end
  end

  # describe 'Boolean filter' do
  #   let!(:available_user) { create :user, name: 'Available user', availability: true }
  #   let!(:unavailable_user) { create :user, name: 'Unavailable user', availability: false }

  #   let(:url) { '/avo/resources/users' }

  #   context 'without default value' do
  #     it 'displays the filter' do
  #       visit url
  #       find('[data-button="resource-filters"]').click

  #       expect(page).to have_text 'Availability filter'
  #       expect(page).to have_text 'Available user'
  #       expect(page).to have_text 'Unavailable user'
  #       expect(page).to have_select 'avo_filters_availability_filter', selected: empty_dash, options: [empty_dash, 'Available', 'Unavailable']
  #     end

  #     it 'changes the filter' do
  #       visit url
  #       find('[data-button="resource-filters"]').click

  #       select 'Unavailable', from: 'avo_filters_availability_filter'
  #       wait_for_loaded

  #       expect(page).to have_text 'Availability filter'
  #       expect(page).not_to have_text 'Available user'
  #       expect(page).to have_text 'Unavailable user'
  #       expect(page).to have_select 'avo_filters_availability_filter', selected: 'Unavailable', options: [empty_dash, 'Available', 'Unavailable']
  #       expect(current_url).to include 'filters='
  #     end

  #     it 'keeps the filter on page refresh' do
  #       visit url
  #       find('[data-button="resource-filters"]').click

  #       select 'Unavailable', from: 'avo_filters_availability_filter'
  #       wait_for_loaded

  #       expect(page).to have_text 'Availability filter'
  #       expect(page).not_to have_text 'Available user'
  #       expect(page).to have_text 'Unavailable user'
  #       expect(page).to have_select 'avo_filters_availability_filter', selected: 'Unavailable', options: [empty_dash, 'Available', 'Unavailable']
  #       expect(current_url).to include 'filters='

  #       visit current_url
  #       find('[data-button="resource-filters"]').click

  #       expect(page).to have_text 'Availability filter'
  #       expect(page).not_to have_text 'Available user'
  #       expect(page).to have_text 'Unavailable user'
  #       expect(page).to have_select 'avo_filters_availability_filter', selected: 'Unavailable', options: [empty_dash, 'Available', 'Unavailable']
  #     end
  #   end

  #   context 'with default to available' do
  #     before do
  #       Avo::Filters::AvailabilityFilter.set_default 'available'
  #     end

  #     after do
  #       Avo::Filters::AvailabilityFilter.set_default ''
  #     end

  #     it 'displays the filter' do
  #       visit url
  #       find('[data-button="resource-filters"]').click

  #       expect(page).to have_text 'Availability filter'
  #       expect(page).to have_text 'Available user'
  #       expect(page).not_to have_text 'Unavailable user'
  #       expect(page).to have_select 'avo_filters_availability_filter', selected: 'Available', options: [empty_dash, 'Available', 'Unavailable']
  #     end

  #     it 'changes the filter' do
  #       visit url
  #       find('[data-button="resource-filters"]').click

  #       select 'Unavailable', from: 'avo_filters_availability_filter'
  #       wait_for_loaded

  #       expect(page).to have_text 'Availability filter'
  #       expect(page).not_to have_text 'Available user'
  #       expect(page).to have_text 'Unavailable user'
  #       expect(page).to have_select 'avo_filters_availability_filter', selected: 'Unavailable', options: [empty_dash, 'Available', 'Unavailable']
  #       expect(current_url).to include 'filters='
  #     end
  #   end
  # end
end
