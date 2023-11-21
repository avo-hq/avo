# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create Via Belongs to', type: :system do
  describe 'edit' do
    let(:course_link) { create(:course_link) }

    context 'with non-searchable belongs_to' do
      let(:fish) { create(:fish, user: create(:user)) }

      it 'successfully creates a new user and assigns it to the comment', :aggregate_failures do
        visit "/admin/resources/fish/#{fish.id}/edit"

        click_on 'Create new user'

        expect do
          within('.modal-container') do
            fill_in 'user_email', with: "#{SecureRandom.hex(12)}@gmail.com"
            fill_in 'user_first_name', with: 'FirstName'
            fill_in 'user_last_name', with: 'LastName'
            fill_in 'user_password', with: 'password'
            fill_in 'user_password_confirmation', with: 'password'
            click_on 'Save'
            sleep 0.2
          end
        end.to change(User, :count).by(1)

        expect(page).to have_select('fish_user_id', selected: User.last.name)

        click_on 'Save'
        sleep 0.2

        expect(fish.reload.user).to eq User.last
      end
    end

    context 'with polymorphic belongs_to' do
      let(:comment) { create(:comment, user: create(:user), commentable: create(:project)) }

      it 'successfully creates a new commentable and assigns it to the comment', :aggregate_failures do
        visit "/admin/resources/comments/#{comment.id}/edit"

        page.select 'Post', from: 'comment_commentable_type'
        click_on 'Create new post'

        expect do
          within('.modal-container') do
            fill_in 'post_name', with: 'Test post'
            click_on 'Save'
            sleep 0.2
          end
        end.to change(Post, :count).by(1)

        expect(page).to have_select('comment_commentable_id', selected: Post.last.name)

        click_on 'Save'
        sleep 0.2

        expect(comment.reload.commentable).to eq Post.last
      end
    end
  end

  context 'with non-searchable belongs_to' do
    it 'successfully creates a new user and assigns it to the comment', :aggregate_failures do
      visit '/admin/resources/fish/new'

      click_on 'Create new user'

      expect do
        within('.modal-container') do
          fill_in 'user_email', with: "#{SecureRandom.hex(12)}@gmail.com"
          fill_in 'user_first_name', with: 'FirstName'
          fill_in 'user_last_name', with: 'LastName'
          fill_in 'user_password', with: 'password'
          fill_in 'user_password_confirmation', with: 'password'
          click_on 'Save'
          sleep 0.2
        end
      end.to change(User, :count).by(1)
      expect(User.last).to have_attributes(
        first_name: 'FirstName',
        last_name: 'LastName'
      )
      expect(page).to have_select('fish_user_id', selected: User.last.name)

      expect do
        click_on 'Save'
        sleep 0.2
      end.to change(Fish, :count).by(1)

      expect(Fish.last.user).to eq User.last
    end
  end

  context 'with polymorphic belongs_to' do
    it 'successfully creates a new commentable and assigns it to the comment', :aggregate_failures do
      visit '/admin/resources/comments/new'

      fill_in 'comment_body', with: 'Test comment'

      page.select 'Post', from: 'comment_commentable_type'
      click_on 'Create new post'

      expect do
        within('.modal-container') do
          fill_in 'post_name', with: 'Test post'
          click_on 'Save'
          sleep 0.2
        end
      end.to change(Post, :count).by(1)

      expect(page).to have_select('comment_commentable_id', selected: Post.last.name)

      expect do
        fill_in 'comment_body', with: 'Test Comment'
        click_on 'Save'
        sleep 0.2
      end.to change(Comment, :count).by(1)

      expect(Comment.last).to have_attributes(
        body: 'Test Comment',
        commentable: Post.last
      )
    end
  end
end
