require 'rails_helper'

RSpec.describe 'Filters', type: :system do
  describe 'Boolean filter without default' do
    let!(:featured_post) { create :post, name: 'Featured post', is_featured: true }
    let!(:unfeatured_post) { create :post, name: 'Unfeatured post', is_featured: false }

    let(:url) { '/avo/resources/posts' }

    it 'displays the filter' do
      visit url
      find('[data-button="resource-filters"]').click

      expect(page).to have_text 'Featured status'
      expect(page).to have_unchecked_field 'Featured'
      expect(page).to have_unchecked_field 'Unfeatured'
      expect(page).to have_text 'Featured post'
      expect(page).to have_text 'Unfeatured post'
      expect(page).to have_button('Reset filters', disabled: true)
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
      expect(page).to have_button('Reset filters', disabled: false)
    end

    it 'changes the query back also with reset' do
      visit url
      find('[data-button="resource-filters"]').click

      check 'Featured'
      wait_for_loaded

      expect(page).to have_text 'Featured post'
      expect(page).not_to have_text 'Unfeatured post'
      expect(current_url).to include 'filters='
      expect(page).to have_button('Reset filters', disabled: false)

      uncheck 'Featured'
      wait_for_loaded

      expect(page).to have_text 'Featured post'
      expect(page).to have_text 'Unfeatured post'
      expect(page).to have_unchecked_field 'Featured'
      expect(page).to have_unchecked_field 'Unfeatured'
      expect(page).to have_button('Reset filters', disabled: false)

      check 'Featured'
      check 'Unfeatured'

      expect(page).to have_text 'Featured post'
      expect(page).to have_text 'Unfeatured post'
      expect(page).to have_checked_field 'Featured'
      expect(page).to have_checked_field 'Unfeatured'
      expect(page).to have_button('Reset filters', disabled: false)

      click_on 'Reset filters'
      wait_for_loaded

      find('[data-button="resource-filters"]').click

      expect(page).to have_text 'Featured post'
      expect(page).to have_text 'Unfeatured post'
      expect(page).to have_unchecked_field 'Featured'
      expect(page).to have_unchecked_field 'Unfeatured'
      expect(current_url).not_to include 'filters='
      expect(page).to have_button('Reset filters', disabled: true)
    end
  end

  describe 'Boolean filter with default' do
    let!(:user) { create :user }

    let!(:team_without_members) { create :team, name: 'Without Members' }
    let!(:team_with_members) { create :team, name: 'With Members' }

    before do
      team_with_members.members << user
    end

    let(:url) { '/avo/resources/teams' }

    it 'displays the filter' do
      visit url
      find('[data-button="resource-filters"]').click

      expect(page).to have_text 'Members filter'
      expect(page).to have_checked_field 'Has Members'
      expect(page).not_to have_text 'Without Members'
      expect(page).to have_text 'With Members'
      expect(page).to have_button('Reset filters', disabled: true)
    end

    it 'changes the query and reset' do
      visit url
      find('[data-button="resource-filters"]').click

      uncheck 'Has Members'
      wait_for_loaded

      expect(page).to have_text 'Members filter'
      expect(page).to have_unchecked_field 'Has Members'
      expect(page).to have_text 'Without Members'
      expect(page).to have_text 'With Members'
      expect(page).to have_button('Reset filters', disabled: false)

      click_on 'Reset filters'
      wait_for_loaded

      find('[data-button="resource-filters"]').click

      expect(page).to have_text 'Members filter'
      expect(page).to have_checked_field 'Has Members'
      expect(page).not_to have_text 'Without Members'
      expect(page).to have_text 'With Members'
      expect(page).to have_button('Reset filters', disabled: true)
    end
  end

  describe 'Select filter' do
    let!(:published_post) { create :post, name: 'Published post', published_at: '2019-12-05 08:27:19.295065' }
    let!(:unpublished_post) { create :post, name: 'Unpublished post', published_at: nil }

    let(:url) { '/avo/resources/posts' }

    context 'without default value' do
      it 'displays the filter' do
        visit url
        find('[data-button="resource-filters"]').click

        expect(page).to have_text 'Published status'
        expect(page).to have_select 'avo_filters_published_filter', selected: empty_dash, options: [empty_dash, 'Published', 'Unpublished']
        expect(page).to have_text 'Published post'
        expect(page).to have_text 'Unpublished post'
        expect(page).to have_button('Reset filters', disabled: true)
      end

      it 'changes the query' do
        visit url
        find('[data-button="resource-filters"]').click

        select 'Published', from: 'avo_filters_published_filter'
        wait_for_loaded

        expect(page).to have_text 'Published post'
        expect(page).not_to have_text 'Unpublished post'
        expect(page).to have_select 'avo_filters_published_filter', selected: 'Published', options: [empty_dash, 'Published', 'Unpublished']
        expect(current_url).to include 'filters='
        expect(page).to have_button('Reset filters', disabled: false)
      end

      it 'changes the query back also with reset' do
        visit url
        find('[data-button="resource-filters"]').click

        select 'Published', from: 'avo_filters_published_filter'
        wait_for_loaded

        expect(page).to have_text 'Published post'
        expect(page).not_to have_text 'Unpublished post'
        expect(page).to have_select 'avo_filters_published_filter', selected: 'Published', options: [empty_dash, 'Published', 'Unpublished']
        expect(current_url).to include 'filters='
        expect(page).to have_button('Reset filters', disabled: false)

        select empty_dash, from: 'avo_filters_published_filter'
        wait_for_loaded

        expect(page).to have_text 'Published post'
        expect(page).to have_text 'Unpublished post'
        expect(page).to have_select 'avo_filters_published_filter', selected: empty_dash, options: [empty_dash, 'Published', 'Unpublished']
        expect(current_url).not_to include 'filters='
        expect(page).to have_button('Reset filters', disabled: true)

        select 'Unpublished', from: 'avo_filters_published_filter'
        wait_for_loaded

        expect(page).not_to have_text 'Published post'
        expect(page).to have_text 'Unpublished post'
        expect(page).to have_select 'avo_filters_published_filter', selected: 'Unpublished', options: [empty_dash, 'Published', 'Unpublished']
        expect(current_url).to include 'filters='
        expect(page).to have_button('Reset filters', disabled: false)

        click_on 'Reset filters'
        wait_for_loaded

        find('[data-button="resource-filters"]').click

        expect(page).to have_text 'Published status'
        expect(page).to have_select 'avo_filters_published_filter', selected: empty_dash, options: [empty_dash, 'Published', 'Unpublished']
        expect(page).to have_text 'Published post'
        expect(page).to have_text 'Unpublished post'
        expect(page).to have_button('Reset filters', disabled: true)
      end
    end
  end

  describe 'Date filter' do
    let!(:january_project) { create :project, name: 'January project', started_at: '2020-01-15 00:00:00' }
    let!(:february_project) { create :project, name: 'February project', started_at: '2020-02-15 00:00:00' }
    let!(:march_project) { create :project, name: 'March project', started_at: '2020-03-15 00:00:00' }

    let(:url) { '/avo/resources/projects' }

    context 'without default value' do
      it 'displays the filter' do
        visit url
        find('[data-button="resource-filters"]').click

        expect(page).to have_text 'Started after filter'
        expect(page).to have_field('avo_filters_started_filter', placeholder: 'Select a date', type: 'hidden')
        expect(page).to have_text 'January project'
        expect(page).to have_text 'February project'
        expect(page).to have_text 'March project'
        expect(page).to have_button('Reset filters', disabled: true)
      end

      it 'changes the query to display all' do
        visit url
        find('[data-button="resource-filters"]').click
        find('.js-flatpickr-input').click

        find("[aria-label='Month']").find(:xpath, 'option[1]').select_option
        find('.numInput.cur-year').set(2020)
        find("[aria-label='January 1, 2020']").click
        wait_for_loaded

        expect(page).to have_text 'Started after filter'
        expect(page).to have_field('avo_filters_started_filter', placeholder: 'Select a date', type: 'hidden')
        expect(page).to have_text 'January project'
        expect(page).to have_text 'February project'
        expect(page).to have_text 'March project'
        expect(page).to have_button('Reset filters', disabled: false)
      end

      it 'changes the query to display one' do
        visit url
        find('[data-button="resource-filters"]').click
        find('.js-flatpickr-input').click

        find("[aria-label='Month']").find(:xpath, 'option[3]').select_option
        find('.numInput.cur-year').set(2020)
        find("[aria-label='March 1, 2020']").click
        wait_for_loaded

        expect(page).to have_text 'Started after filter'
        expect(page).to have_field('avo_filters_started_filter', placeholder: 'Select a date', type: 'hidden')
        expect(page).not_to have_text 'January project'
        expect(page).not_to have_text 'February project'
        expect(page).to have_text 'March project'
        expect(page).to have_button('Reset filters', disabled: false)
      end

      it 'changes the query to display none' do
        visit url
        find('[data-button="resource-filters"]').click
        find('.js-flatpickr-input').click

        find("[aria-label='Month']").find(:xpath, 'option[5]').select_option
        find('.numInput.cur-year').set(2020)
        find("[aria-label='May 1, 2020']").click
        wait_for_loaded

        expect(page).to have_text 'Started after filter'
        expect(page).to have_field('avo_filters_started_filter', placeholder: 'Select a date', type: 'hidden')
        expect(page).not_to have_text 'January project'
        expect(page).not_to have_text 'February project'
        expect(page).not_to have_text 'March project'
        expect(page).to have_text 'No projects found'
        expect(page).to have_button('Reset filters', disabled: false)
      end
    end
  end

  describe 'Date filter with range' do
    let!(:march_birthday) { create :user, birthday: '1997-03-15' }
    let!(:may_birthday) { create :user, birthday: '2000-05-15' }
    let!(:july_birthday) { create :user, birthday: '2003-07-15' }

    let(:url) { '/avo/resources/users' }

    context 'without default value' do
      it 'displays the filter' do
        visit url
        find('[data-button="resource-filters"]').click

        expect(page).to have_text 'Birthday filter'
        expect(page).to have_field('avo_filters_birthday_filter', placeholder: 'Select a range', type: 'hidden')
        expect(page).to have_text 'March 15th 1997'
        expect(page).to have_text 'May 15th 2000'
        expect(page).to have_text 'July 15th 2003'
        expect(page).to have_button('Reset filters', disabled: true)
      end

      it 'changes the query to display all' do
        visit url
        find('[data-button="resource-filters"]').click
        find('.js-flatpickr-input').click

        find("[aria-label='Month']").find(:xpath, 'option[1]').select_option
        find('.numInput.cur-year').set(1990)
        find("[aria-label='January 1, 1990']").click
        find('.numInput.cur-year').set(2005)
        find("[aria-label='January 1, 2005']").click
        wait_for_loaded

        expect(page).to have_text 'Birthday filter'
        expect(page).to have_field('avo_filters_birthday_filter', placeholder: 'Select a range', type: 'hidden')
        expect(page).to have_text 'March 15th 1997'
        expect(page).to have_text 'May 15th 2000'
        expect(page).to have_text 'July 15th 2003'
        expect(page).to have_button('Reset filters', disabled: false)
      end

      it 'changes the query to display one' do
        visit url
        find('[data-button="resource-filters"]').click
        find('.js-flatpickr-input').click

        find("[aria-label='Month']").find(:xpath, 'option[1]').select_option
        find('.numInput.cur-year').set(2001)
        find("[aria-label='January 1, 2001']").click
        find('.numInput.cur-year').set(2005)
        find("[aria-label='January 1, 2005']").click
        wait_for_loaded

        expect(page).to have_text 'Birthday filter'
        expect(page).to have_field('avo_filters_birthday_filter', placeholder: 'Select a range', type: 'hidden')
        expect(page).not_to have_text 'March 15th 1997'
        expect(page).not_to have_text 'May 15th 2000'
        expect(page).to have_text 'July 15th 2003'
        expect(page).to have_button('Reset filters', disabled: false)
      end

      it 'changes the query to display none' do
        visit url
        find('[data-button="resource-filters"]').click
        find('.js-flatpickr-input').click

        find("[aria-label='Month']").find(:xpath, 'option[1]').select_option
        find('.numInput.cur-year').set(2007)
        find("[aria-label='January 1, 2007']").click
        find('.numInput.cur-year').set(2010)
        find("[aria-label='January 1, 2010']").click
        wait_for_loaded

        expect(page).to have_text 'Birthday filter'
        expect(page).to have_field('avo_filters_birthday_filter', placeholder: 'Select a range', type: 'hidden')
        expect(page).not_to have_text 'March 15th 1997'
        expect(page).not_to have_text 'May 15th 2000'
        expect(page).not_to have_text 'July 15th 2003'
        expect(page).to have_text 'No users found'
        expect(page).to have_button('Reset filters', disabled: false)
      end
    end
  end
end
