require 'rails_helper'

RSpec.describe 'Placeholders', type: :system do
  describe 'with regular input' do
    let!(:user) { create :user }

    context 'edit' do
      it 'checks for placeholder visibility' do
        visit "/avocado/resources/users/#{user.id}/edit"

        fill_in 'first_name', with: ''
        fill_in 'last_name', with: ''

        expect(find_field('first_name')[:placeholder]).to have_text('John')
        expect(find_field('last_name')[:placeholder]).to have_text('Doe')
      end
    end
  end
end
