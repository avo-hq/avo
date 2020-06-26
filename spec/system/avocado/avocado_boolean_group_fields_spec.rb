require 'rails_helper'

RSpec.describe 'BooleanGroupFields', type: :system do
  describe 'with regular input' do
    let!(:user) { create :user }

    context 'index' do
      it 'displays the users name' do
        visit '/avocado/resources/users'

        expect(page).to have_text 'ROLES'
        expect(page).to have_text 'View'
        click_on 'View'
        wait_for_loaded

        expect(page).to have_text 'Administrator'
        expect(page).to have_text 'Manager'
      end
    end

    context 'show' do
      it 'displays the users roles' do
        visit "/avocado/resources/users/#{user.id}"

        expect(page).to have_text 'Roles'
        expect(page).to have_text 'Administrator'
        expect(page).to have_text 'Manager'
      end
    end

    context 'edit' do
      it 'changes the users roles' do
        visit "/avocado/resources/users/#{user.id}/edit"

        check 'admin'
        uncheck 'manager'

        click_on 'Save'
        wait_for_loaded

        user_id = page.find('[field-id="id"] [data-slot="value"]').text
        expect(current_path).to eql "/avocado/resources/users/#{user_id}"

        # TODO replace page.find('[field-id="roles"] [data-slot="value"]').text with method: find_field_value_element('roles') when merging to master (currently unavailable)
        expect(page.find('[field-id="roles"] [data-slot="value"]').text).to have_text '✅ Administrator'
        expect(page.find('[field-id="roles"] [data-slot="value"]').text).to have_text '❌ Manager'
      end
    end
  end
end
