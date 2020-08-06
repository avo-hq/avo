require 'rails_helper'

RSpec.describe 'TextField', type: :system do
  describe 'with regular input' do
    let!(:user) { create :user }

    context 'index' do
      it 'displays the users first name' do
        visit '/avo/resources/users'

        expect(page).to have_text user.first_name
      end
    end

    context 'show' do
      it 'displays the users first name' do
        visit "/avo/resources/users/#{user.id}"

        expect(page).to have_text user.first_name
      end
    end

    context 'edit' do
      it 'has the users name prefilled' do
        visit "/avo/resources/users/#{user.id}/edit"

        expect(find_field('first_name').value).to eq user.first_name
      end

      it 'changes the users name' do
        visit "/avo/resources/users/#{user.id}/edit"

        fill_in 'first_name', with: 'Jack Jack Jack'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/users/#{user.id}"
        expect(page).to have_text 'Jack Jack Jack'
      end
    end
  end
end
