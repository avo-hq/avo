require 'rails_helper'

RSpec.feature 'HasManyField', type: :feature do
  let!(:user) { create :user }

  subject { visit url; page }

  context 'show' do
    # Test the frame directly
    let(:url) { "/avo/resources/users/#{user.id}/posts?frame_name=has_many_field_posts" }
    # let(:url) { "/avo/resources/users/#{user.id}" }

    describe 'without a related post' do
      it { is_expected.to have_text 'No related posts found' }

      it 'creates a post' do
        visit url

        click_on 'Create new post'

        expect(page).to have_current_path "/avo/resources/posts/new?via_relation=user&via_relation_class=User&via_resource_id=#{user.id}"

        expect(page).to have_select 'post_user_id', selected: user.name, disabled: true

        fill_in 'post_name', with: 'New post name'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/users/#{user.id}"
        expect(user.posts.last.name).to eql 'New post name'
        expect(user.posts.last.user_id).to eql user.id
      end
    end

    describe 'with a related post' do
      let!(:post) { create :post, user: user }

      it 'navigates to a view post page' do
        visit url

        click_on 'Create new post'

        expect(page).to have_current_path "/avo/resources/posts/new?via_relation=user&via_relation_class=User&via_resource_id=#{user.id}"
      end

      it 'navigates to an edit post page' do
        visit url

        find("[data-component='resources-index'][data-resource-name='posts'] [data-control='edit']").click

        expect(page).to have_current_path "/avo/resources/posts/#{post.id}/edit?viaResourceName=users&viaResourceId=#{user.id}"
      end

      it 'deletes a post' do
        visit url

        expect {
          find("tr[data-resource-id='#{post.id}'] [data-control='destroy']").click
        }.to change(Post, :count).by -1

        expect(page).to have_current_path "/avo/resources/users/#{user.id}"
        expect(page).not_to have_text post.name
      end
    end
  end
end
