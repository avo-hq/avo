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
    let!(:january_project) { create :project, name: 'January project', started_at: '2020-01-01 00:00:00' }
    let!(:february_project) { create :project, name: 'February project', started_at: '2020-02-01 00:00:00' }
    let!(:march_project) { create :project, name: 'March project', started_at: '2020-03-01 00:00:00' }

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

      it 'changes the query' do
        visit url
        find('[data-button="resource-filters"]').click

        fill_in_date_picker('Started after filter', with: '1969-07-20')
        wait_for_loaded

        expect(page).to have_text 'Started after filter'
        expect(page).to have_field('avo_filters_started_filter', placeholder: 'Select a date', type: 'hidden')
        expect(page).to have_text 'January project'
        expect(page).to have_text 'February project'
        expect(page).to have_text 'March project'
        expect(page).to have_button('Reset filters', disabled: true)
      end
    end
  end

  # def fill_in_date_manually(label_text, with:)
  #   with_open_flatpickr(label_text) do |field|
  #     fill_in field[:id], with: with
  #   end
  # end

  def fill_in_date_picker(label_text, with:)
    within_open_flatpickr(label_text) do
      within_flatpickr_months do
        select_flatpickr_month(with.split('-')[1])

        fill_in_flatpickr_year(with.split('-')[0])

        click_on_flatpickr_day(with.split('-')[2])
      end
    end
  end

  def with_open_flatpickr(label_text)

    field_label = find(:label, text: label_text)

    date_field = field_label.sibling('.flatpickr-input')
    date_field.click # Open the widget

    yield(date_field)

    date_field.send_keys :tab # Close the date picker widget
  end

  def within_open_flatpickr(label_text)
    with_open_flatpickr(label_text) do
      within find(:xpath, "/html/body/div[contains(@class, 'flatpickr-calendar')]") { yield }
    end
  end

  def within_flatpickr_months
    within find('.flatpickr-months .flatpickr-month .flatpickr-current-month') { yield }
  end

  def select_flatpickr_month(month)
    find("select.flatpickr-monthDropdown-months > option:nth-child(#{month.to_i})").select_option
  end

  def fill_in_flatpickr_year(year)
    find('input.cur-year').set(year)
  end

  def click_on_flatpickr_day(day)
    within_flatpickr_days do
      find('span', text: day).click
    end
  end

  def within_flatpickr_days
    within find('.flatpickr-innerContainer > .flatpickr-rContainer > .flatpickr-days') { yield }
  end

  # def fill_in_date_with_js(label_text, with:)
  #   date_field = find(:label, text: label_text).sibling('.flatpickr-input')

  #   script = "document.querySelector('##{date_field[:id]}').flatpickr().setDate('#{with}');"

  #   page.execute_script(script)
  # end
end
