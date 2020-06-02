require 'rails_helper'

RSpec.describe 'TextField', type: :system do
  describe 'with regular input' do
    let!(:user) { create :user }

    context 'index' do
      it 'displays the users name' do
        visit '/avocado/resources/users'

        expect(page).to have_text user.name
      end
    end

    context 'show' do
      it 'displays the users name' do
        visit "/avocado/resources/users/#{user.id}"

        expect(page).to have_text user.name
      end
    end

    context 'edit' do
      it 'has the users name prefilled' do
        visit "/avocado/resources/users/#{user.id}/edit"

        expect(find_field('name').value).to eq user.name
      end

      it 'changes the users name' do
        visit "/avocado/resources/users/#{user.id}/edit"

        fill_in 'name', with: 'Jack Jack Jack'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/users/#{user.id}"
        expect(page).to have_text 'Jack Jack Jack'
      end
    end
  end
end
