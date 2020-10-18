require 'rails_helper'

RSpec.describe 'Actions', type: :system do
  let!(:user) { create :user, active: true }

  context 'index' do
    describe 'without actions attached' do
      let(:url) { '/avo/resources/teams' }

      it 'does not display the actions button' do
        visit url

        expect(page).not_to have_text 'Actions'
      end
    end

    describe 'with actions attached' do
      let!(:second_user) { create :user, active: true }
      let(:url) { '/avo/resources/users' }

      it 'displays the actions button disabled' do
        visit url

        expect(page).to have_button('Actions', disabled: true)
      end

      it 'enables the button when selecting a record' do
        visit url

        expect(page).to have_button('Actions', disabled: true)

        find("tr[resource-name=users][resource-id='#{user.id}'] input[type=checkbox]").click

        expect(page).to have_button('Actions', disabled: false)
      end

      it 'runs the action' do
        visit url

        expect(user.active).to be true
        expect(second_user.active).to be true

        find("tr[resource-name=users][resource-id='#{user.id}'] input[type=checkbox]").click
        find("tr[resource-name=users][resource-id='#{second_user.id}'] input[type=checkbox]").click

        expect(page).to have_button('Actions', disabled: false)

        click_on 'Actions'
        click_on 'Mark inactive'
        click_on 'Run'

        wait_for_loaded

        expect(user.reload.active).to be false
        expect(second_user.reload.active).to be false
      end

      describe 'when resources still selected' do
        it 'runs the action' do
          visit url

          expect(page).to have_button('Actions', disabled: true)

          find("tr[resource-name=users][resource-id='#{user.id}'] input[type=checkbox]").click

          expect(page).to have_button('Actions', disabled: false)

          click_on 'Posts'
          wait_for_loaded
          click_on 'Users'
          wait_for_loaded

          expect(page).to have_button('Actions', disabled: true)
        end
      end
    end
  end

  context 'show' do
    let!(:user) { create :user, active: true }
    let!(:post) { create :post, published_at: nil }

    describe 'with fields' do
      let(:url) { "/avo/resources/users/#{user.id}" }

      it 'lists the action' do
        visit url

        click_on 'Actions'

        expect(find('.js-actions-panel')).to have_text 'Mark inactive'
      end

      it 'opens the action modal and executes the action' do
        visit url
        expect(find_field_value_element('active')).to have_css 'svg[data-checked="1"]'

        click_on 'Actions'
        click_on 'Mark inactive'

        expect(find('.vm--modal')).to have_text 'Mark inactive'
        expect(find('.vm--modal')).to have_text 'Notify user'
        expect(find('.vm--modal')).to have_text 'Message'
        expect(find('.vm--modal #message').value).to eq 'Your account has been marked as inactive.'

        check 'notify_user'
        fill_in 'message', with: 'Your account has been marked as very inactive.'

        click_on 'Run'
        wait_for_loaded

        expect(page).to have_text 'Perfect!'
        expect(user.reload.active).to be false
        expect(find_field_value_element('active')).to have_css 'svg[data-checked="0"]'
      end
    end

    describe 'without fields' do
      let(:url) { "/avo/resources/posts/#{post.id}" }

      it 'lists the action with a custom name' do
        visit url

        click_on 'Actions'

        expect(find('.js-actions-panel')).to have_text 'Toggle post published'
      end

      it 'opens the action modal and executes the action' do
        visit url

        click_on 'Actions'
        click_on 'Toggle post published'

        expect(find('.vm--modal')).to have_text 'Toggle post published'
        expect(find('.vm--modal')).to have_text 'Are you sure, sure?'
        expect(find('.vm--modal')).to have_text 'Toggle'
        expect(find('.vm--modal')).to have_text "Don't toggle yet"

        click_on 'Toggle'

        expect(page).to have_text 'Perfect!'
        expect(post.reload.published_at).not_to be nil
        expect(current_path).to eq '/avo/resources/posts'
      end
    end
  end
end
