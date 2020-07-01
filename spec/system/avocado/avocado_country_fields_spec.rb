require 'rails_helper'

RSpec.describe 'CountryFields', type: :system do
  describe 'with regular input' do
    let!(:user) { create :user, country: 'AT' }

    context 'index' do
      it 'displays the users country' do
        visit '/avocado/resources/users'

        expect(page).to have_text user.country
      end
    end

    context 'show' do
      it 'displays the users country' do
        visit "/avocado/resources/users/#{user.id}"

        expect(page).to have_text user.country
      end
    end

    context 'edit' do
      it 'has the users country prefilled' do
        visit "/avocado/resources/users/#{user.id}/edit"

        expect(page).to have_select 'country', selected: 'Austria'
      end

      it 'changes the users name' do
        visit "/avocado/resources/users/#{user.id}/edit"

        find('#country').find(:xpath, 'option[2]').select_option

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/users/#{user.id}"
        expect(page).to have_text 'AW'
      end
    end
  end
end
