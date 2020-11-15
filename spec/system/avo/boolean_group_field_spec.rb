require 'rails_helper'

RSpec.describe 'BooleanGroupFields', type: :system do
  describe 'with regular input' do
    let!(:user) { create :user }

    context 'index' do
      it 'displays the users name' do
        visit '/avo/resources/users'

        expect(page).to have_text 'ROLES'
        expect(page).to have_text 'View'
        find("tr[resource-id='#{user.id}'] [field-id='roles']").find('a', text: 'View').click
        wait_for_loaded

        expect(page).to have_text 'Administrator'
        expect(page).to have_text 'Manager'
        expect(page).to have_text 'Writer'
      end
    end

    context 'show' do
      it 'displays the users roles' do
        visit "/avo/resources/users/#{user.id}"

        expect(page).to have_text 'Roles'
        expect(page).to have_text 'Administrator'
        expect(page).to have_text 'Manager'
        expect(page).to have_text 'Writer'
      end
    end

    context 'edit' do
      it 'changes the users roles' do
        visit "/avo/resources/users/#{user.id}/edit"

        check 'admin'
        uncheck 'manager'
        uncheck 'writer'

        click_on 'Save'
        wait_for_loaded

        user_id = page.find('[field-id="id"] [data-slot="value"]').text
        expect(current_path).to eql "/avo/resources/users/#{user_id}"

        expect(page.all("[field-id='roles'] [data-slot='value'] svg")[0]['class']).to have_text 'text-green-600'
        expect(find_field_value_element(:roles)).to have_text 'Administrator'
        expect(page.all("[field-id='roles'] [data-slot='value'] svg")[1]['class']).to have_text 'text-red-600'
        expect(find_field_value_element(:roles)).to have_text 'Manager'
        expect(page.all("[field-id='roles'] [data-slot='value'] svg")[2]['class']).to have_text 'text-red-600'
        expect(find_field_value_element(:roles)).to have_text 'Writer'
      end
    end
  end
end
