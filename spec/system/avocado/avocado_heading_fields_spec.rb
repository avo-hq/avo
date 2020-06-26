require 'rails_helper'

RSpec.describe 'HeadingFields', type: :system do
  describe 'with regular input' do
    let!(:user) { create :user }

    context 'show' do
      it 'checks for header' do
        visit "/avocado/resources/users/#{user.id}"

        expect(page).to have_text 'PERSONAL DOCUMENTS'
      end
    end

    context 'edit' do
      it 'checks for header' do
        visit "/avocado/resources/users/#{user.id}/edit"

        expect(page).to have_text 'PERSONAL DOCUMENTS'
      end
    end
  end
end
