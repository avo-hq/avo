require 'rails_helper'

RSpec.describe "KeyValueFields", type: :system do
  describe 'with regular input' do
    let!(:user) { create :user }

    context 'index' do
      it 'displays the users meta' do
        visit '/avocado/resources/users'

        expect(page).to have_text 'META'
        expect(page.find('[field-id="meta"]')).to have_text 'View'
        find('[field-id="meta"]').find('button').click
        wait_for_loaded

        # no value is stored for meta atm
        # expect(page.find('[field-id="meta"]')).to have_text 'CHEIE'
        # expect(page.find('[field-id="meta"]')).to have_text 'bar'
      end
    end

    context 'show' do
      it 'displays the users meta' do
        visit "/avocado/resources/users/#{user.id}"

        expect(page).to have_text 'Meta'
      end
    end

    context 'edit' do
      # TODO when saving will work
    end
  end
end
