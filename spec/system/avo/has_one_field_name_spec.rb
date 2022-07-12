require 'rails_helper'

RSpec.describe 'HasOneFieldName', type: :system do
  let!(:user) { create :user }
  let!(:post) { create :post }

  subject {
    visit url
    page
  }

  context 'show' do
    let(:url) { "/admin/resources/users/#{user.id}" }

    describe 'without a related post' do
      it 'attaches and detaches a post' do
        visit url

        scroll_to second_tab_group

        click_tab 'Main post', within: second_tab_group
        expect(page).to have_text 'Attach Main post'

        click_on 'Attach Main post'

        wait_for_loaded

        expect(page).to have_text 'Choose post'

        expect(page).to have_select 'fields_related_id', selected: "Choose an option"
        select post.name, from: 'fields_related_id'

        click_on 'Attach'
        wait_for_loaded

        scroll_to second_tab_group

        click_tab 'Main post', within: second_tab_group

        expect(page).to have_text 'Post attached.'
        expect(page).not_to have_text 'Choose post'
        expect(page).to have_text post.name

        expect(user.posts.pluck('id')).to include post.id

        expect(page).to have_text 'Main post'
        expect(page).to have_text 'Detach main post'

        accept_alert do
          click_on 'Detach main post'
        end
        wait_for_loaded

        click_tab 'Main post', within: second_tab_group

        expect(page).to have_text 'Post detached.'
        expect(page).not_to have_text 'Detach main post'
        expect(page).to have_text 'Attach Main post'
        expect(user.posts.pluck('id')).not_to include post.id
      end
    end
  end
end
