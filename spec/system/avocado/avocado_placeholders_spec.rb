require 'rails_helper'

RSpec.describe 'Placeholders', type: :system do
  describe 'with regular input' do
    let!(:user) { create :user }

    context 'edit' do
      it 'checks for placeholder visibility' do
        visit "/avocado/resources/users/#{user.id}/edit"

        fill_in 'name', with: ''

        expect(find_field('name')[:placeholder]).to have_text('John Doe')
      end
    end
  end
end
