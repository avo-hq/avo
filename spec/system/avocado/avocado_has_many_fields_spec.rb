require 'rails_helper'

RSpec.describe 'HasManyField', type: :system do
  let!(:user) { create :user }

  subject { visit url; page }

  context 'show' do
    let(:url) { "/avocado/resources/users/#{user.id}" }

    describe 'without a related post' do
      it { is_expected.to have_text 'No related posts found' }

      it 'creates a post' do
        visit url

        wait_for_loaded

        click_on 'Create new post'

        expect(page).to have_current_path "/avocado/resources/posts/new?viaRelationship=posts&viaResourceName=users&viaResourceId=#{user.id}"

        expect(page).to have_select 'user', selected: user.name, disabled: true

        fill_in :name, with: 'New post name'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/users/#{user.id}"
        expect(page).to have_text 'New post name'
      end
    end

    describe 'with a related post' do
      let!(:post) { create :post, user: user }

      it 'navigates to a view post page' do
        visit url

        find("[data-component='resources-index'][data-resource-name='posts'] [data-control='view']").click

        expect(page).to have_current_path "/avocado/resources/posts/#{post.id}"
      end

      it 'navigates to an edit post page' do
        visit url

        find("[data-component='resources-index'][data-resource-name='posts'] [data-control='edit']").click

        expect(page).to have_current_path "/avocado/resources/posts/#{post.id}/edit?viaResourceName=users&viaResourceId=#{user.id}"
      end

      it 'deletes a post' do
        visit url

        expect {
          find("[data-component='resources-index'][data-resource-name='posts'] [data-control='delete']").click
          find("[data-modal-button='confirm']").click
          wait_for_loaded
        }.to change(Post, :count).by -1

        expect(page).to have_current_path "/avocado/resources/users/#{user.id}"
        expect(page).not_to have_text post.name
      end
    end
  end
end
