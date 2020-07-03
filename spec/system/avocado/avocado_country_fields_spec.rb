require 'rails_helper'

RSpec.describe 'CountryField', type: :system do
  describe 'without a value' do
    let!(:user) { create :user, country: nil }

    subject { visit url; find_field_element(:country) }

    context 'index' do
      let!(:url) { '/avocado/resources/users' }

      it { is_expected.to have_text empty_dash }
    end

    context 'show' do
      let!(:url) { "/avocado/resources/users/#{user.id}" }

      it { is_expected.to have_text empty_dash }
    end

    context 'edit' do
      let!(:url) { "/avocado/resources/users/#{user.id}/edit" }

      it 'is hidden' do
        visit url

        expect(page).to have_select 'country', selected: 'Choose a country'
      end
    end
  end

  describe 'with RO as a value' do
    let(:country_code) { 'RO' }
    let(:country_name) { 'Romania' }
    let!(:user) { create :user, country: country_code }

    subject { visit url; find_field_element(:country) }

    context 'index' do
      let!(:url) { '/avocado/resources/users' }

      it { is_expected.to have_text country_name }
    end

    context 'show' do
      let!(:url) { "/avocado/resources/users/#{user.id}" }

      it { is_expected.to have_text country_name }
    end

    context 'edit' do
      let!(:url) { "/avocado/resources/users/#{user.id}/edit" }

      it { is_expected.to have_select 'country', selected: country_name }

      it 'changes the country' do
        visit url

        select 'United States Minor Outlying Islands', from: :country

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/users/#{user.id}"
        expect(find_field_element(:country)).to have_text 'United States Minor Outlying Islands'
        expect(user.reload.country).to eql 'UM'
      end
    end
  end
end
