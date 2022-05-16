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

    describe 'without a related user' do
      it 'attaches a post' do
        visit url
        expect(page).to have_text 'Attach Main post'

        click_on 'Attach Main post'
        wait_for_loaded
        expect(page).to have_text 'Choose post'

        expect(page).to have_select 'fields_related_id', selected: "Choose an option"
        select post.name, from: 'fields_related_id'

        click_on 'Attach'
        wait_for_loaded

        expect(page).to have_text 'Post attached.'
        expect(page).not_to have_text 'Choose post'
        expect(page).to have_text post.name

        expect(user.posts.pluck('id')).to include post.id
      end
    end
  end
end
