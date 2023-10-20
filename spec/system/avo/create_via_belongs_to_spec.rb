# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create Via Belongs to', type: :system do
  describe 'edit' do
    let(:course_link) { create(:course_link) }

    context 'with searchable belongs_to' do
      it 'successfully creates a new course and assigns it to the course link', :aggregate_failures do
        visit "/admin/resources/course_links/#{course_link.id}/edit"

        click_on 'Create new course'

        expect do
          within('.modal-container') do
            fill_in 'course_name', with: 'Test course'
            click_on 'Save'
            sleep 0.2
          end
        end.to change(Course, :count).by(1)

        expect(find_field(id: 'course_link_course_id').value).to eq 'Test course'

        click_on 'Save'
        sleep 0.2

        expect(course_link.reload.course).to eq Course.last
      end
    end

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

    context 'with searchable, polymorphic belongs_to' do
      let(:review) { create(:review, user: create(:user), reviewable: create(:project)) }

      it 'successfully creates reviewable and assigns it to the review', :aggregate_failures do
        visit "/admin/resources/reviews/#{review.id}/edit"

        page.select 'Fish', from: 'review_reviewable_type'
        click_on 'Create new fish'

        expect do
          within('.modal-container') do
            fill_in 'fish_name', with: 'Test fish'
            click_on 'Save'
            sleep 0.2
          end
        end.to change(Fish, :count).by(1)

        expect(find_field(id: 'review_reviewable_id').value).to eq 'Test fish'

        click_on 'Save'
        sleep 0.2

        expect(review.reload.reviewable).to eq Fish.last
      end
    end
  end

  describe 'new' do
    context 'with searchable belongs_to' do
      it 'successfully creates a new course and assigns the value to the field in the form' do
        visit '/admin/resources/course_links/new'

        click_on 'Create new course'

        expect do
          within('.modal-container') do
            fill_in 'course_name', with: 'Test course'
            click_on 'Save'
            sleep 0.2
          end
        end.to change(Course, :count).by(1)

        expect(find_field(id: 'course_link_course_id').value).to eq 'Test course'

        expect do
          fill_in('course_link_link', with: 'https://www.example.com')
          click_on 'Save'
          sleep 0.2
        end.to change(Course::Link, :count).by(1)

        expect(Course::Link.last.course).to eq Course.last
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

  context 'with searchable, polymorphic belongs_to' do
    it 'successfully creates reviewable and assigns it to the review', :aggregate_failures do
      visit '/admin/resources/reviews/new'

      page.select 'Fish', from: 'review_reviewable_type'
      click_on 'Create new fish'

      expect do
        within('.modal-container') do
          fill_in 'fish_name', with: 'Test fish'
          click_on 'Save'
          sleep 0.2
        end
      end.to change(Fish, :count).by(1)

      expect(find_field(id: 'review_reviewable_id').value).to eq 'Test fish'

      expect do
        fill_in 'review_body', with: 'Test review'
        click_on 'Save'
        sleep 0.2
      end.to change(Review, :count).by(1)
      expect(Review.last).to have_attributes(
        body: 'Test review',
        reviewable: Fish.last
      )
    end
  end
end
