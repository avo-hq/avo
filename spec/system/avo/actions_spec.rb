require 'rails_helper'

RSpec.describe 'Actions', type: :system do
  let!(:user) { create :user }
  let!(:person) { create :person }

  describe 'action visibility option' do
    context 'index' do
      it 'finds an action on index' do
        visit '/admin/resources/users'

        click_on 'Actions'

        expect(page).to have_link 'Dummy action'
      end
    end

    context 'show' do
      it 'does not find an action on show' do
        visit "/admin/resources/users/#{user.id}"

        click_on 'Actions'

        expect(page).not_to have_link 'Dummy action'
      end
    end
  end

  describe 'action button should be hidden if no actions present' do
    context 'index' do
      it 'does not see the actions button' do
        visit '/admin/resources/people'

        expect(page).not_to have_button 'Actions'
      end
    end

    context 'show' do
      it 'does not see the actions button' do
        visit "/admin/resources/people/#{person.id}"

        expect(page).not_to have_button 'Actions'
      end
    end
  end

  #   let!(:roles) { { admin: false, manager: false, writer: false } }
  #   let!(:user) { create :user, active: true, roles: roles }

  #   context 'index' do
  #     describe 'without actions attached' do
  #       let(:url) { '/admin/resources/teams' }

  #       it 'does not display the actions button' do
  #         visit url

  #         expect(page).not_to have_text 'Actions'
  #       end
  #     end

  #     describe 'with actions attached' do
  #       let!(:roles) { { admin: false, manager: false, writer: false } }
  #       let!(:second_user) { create :user, active: true, roles: roles }
  #       let(:url) { '/admin/resources/users' }

  #       it 'displays the actions button disabled' do
  #         visit url

  #         expect(page).to have_button('Actions', disabled: true)
  #       end

  #       it 'enables the button when selecting a record' do
  #         visit url

  #         expect(page).to have_button('Actions', disabled: true)

  #         find("tr[resource-name=users][resource-id='#{user.id}'] input[type=checkbox]").click

  #         expect(page).to have_button('Actions', disabled: false)
  #       end

  #       it 'runs the action' do
  #         visit url

  #         expect(user.active).to be true
  #         expect(second_user.active).to be true

  #         find("tr[resource-name=users][resource-id='#{user.id}'] input[type=checkbox]").click
  #         find("tr[resource-name=users][resource-id='#{second_user.id}'] input[type=checkbox]").click

  #         expect(page).to have_button('Actions', disabled: false)

  #         click_on 'Actions'
  #         click_on 'Mark inactive'
  #         click_on 'Run'

  #         wait_for_loaded

  #         expect(user.reload.active).to be false
  #         expect(second_user.reload.active).to be false
  #       end

  #       it 'runs the action without confirmation' do
  #         visit url

  #         expect(user.roles['admin']).to be false
  #         expect(second_user.roles['admin']).to be false

  #         find("tr[resource-name=users][resource-id='#{user.id}'] input[type=checkbox]").click
  #         find("tr[resource-name=users][resource-id='#{second_user.id}'] input[type=checkbox]").click

  #         expect(page).to have_button('Actions', disabled: false)

  #         click_on 'Actions'
  #         click_on 'Make admin'

  #         wait_for_loaded

  #         # expect(page).to have_text 'New admin(s) on the board!'
  #         expect(user.reload.roles['admin']).to be true
  #         expect(second_user.reload.roles['admin']).to be true
  #       end

  #       describe 'when resources still selected' do
  #         it 'runs the action' do
  #           visit url

  #           expect(page).to have_button('Actions', disabled: true)

  #           find("tr[resource-name=users][resource-id='#{user.id}'] input[type=checkbox]").click

  #           expect(page).to have_button('Actions', disabled: false)

  #           click_on 'Posts'
  #           wait_for_loaded
  #           click_on 'Users'
  #           wait_for_loaded

  #           expect(page).to have_button('Actions', disabled: true)
  #         end
  #       end
  #     end
  #   end

  #   context 'show' do
  #     let!(:roles) { { admin: false, manager: false, writer: false } }
  #     let!(:user) { create :user, active: true, roles: roles }
  #     let!(:post) { create :post, published_at: nil }

  #     describe 'with fields' do
  #       let(:url) { "/admin/resources/users/#{user.id}" }

  #       it 'lists the action' do
  #         visit url

  #         click_on 'Actions'

  #         expect(find('.js-actions-panel')).to have_text 'Mark inactive'
  #       end

  #       it 'opens the action modal and executes the action' do
  #         visit url
  #         expect(find_field_value_element('active')).to have_css 'svg[data-checked="1"]'

  #         click_on 'Actions'
  #         click_on 'Mark inactive'

  #         expect(find('.vm--modal')).to have_text 'Mark inactive'
  #         expect(find('.vm--modal')).to have_text 'Notify user'
  #         expect(find('.vm--modal')).to have_text 'Message'
  #         expect(find('.vm--modal #message').value).to eq 'Your account has been marked as inactive.'

  #         check 'notify_user'
  #         fill_in 'message', with: 'Your account has been marked as very inactive.'

  #         click_on 'Run'
  #         wait_for_loaded

  #         expect(page).to have_text 'Perfect!'
  #         expect(user.reload.active).to be false
  #         expect(find_field_value_element('active')).to have_css 'svg[data-checked="0"]'
  #       end

  #       it 'executes the action without confirmation' do
  #         visit url

  #         expect(find_field_value_element('roles').find('svg', match: :first)['data-checked']).to eq '0'

  #         click_on 'Actions'
  #         click_on 'Make admin'

  #         sleep 0.2
  #         wait_for_loaded

  #         expect(user.reload.roles['admin']).to be true
  #         expect(find_field_value_element('roles').find('svg', match: :first)['data-checked']).to eq '1'
  #       end
  #     end

  #     describe 'without fields' do
  #       let(:url) { "/admin/resources/posts/#{post.id}" }

  #       it 'lists the action with a custom name' do
  #         visit url

  #         click_on 'Actions'

  #         expect(find('.js-actions-panel')).to have_text 'Toggle post published'
  #       end

  #       it 'opens the action modal and executes the action' do
  #         visit url

  #         click_on 'Actions'
  #         click_on 'Toggle post published'

  #         expect(find('.vm--modal')).to have_text 'Toggle post published'
  #         expect(find('.vm--modal')).to have_text 'Are you sure, sure?'
  #         expect(find('.vm--modal')).to have_text 'Toggle'
  #         expect(find('.vm--modal')).to have_text "Don't toggle yet"

  #         click_on 'Toggle'

  #         expect(page).to have_text 'Perfect!'
  #         expect(post.reload.published_at).not_to be nil
  #         expect(current_path).to eq '/admin/resources/posts'
  #       end
  #     end
  #   end
end
