require 'rails_helper'

RSpec.describe 'HelpText', type: :system do
  describe 'with regular input' do
    let!(:user) { create :user}

    context 'edit' do
      it 'checks for help text visibility' do
        visit "/avocado/resources/users/#{user.id}/edit"

        expect(find_field_element('description')).to have_text('Don\'t expose private data.')
      end

      it 'checks for help html visibility' do
        visit "/avocado/resources/users/#{user.id}/edit"

        expect(find_field_element('password')).to have_text('Verify password strength')
        expect(find_field_element('password')).to have_selector('a[href="http://www.passwordmeter.com/"]')
      end
    end
  end
end
