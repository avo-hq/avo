# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Post comments use_resource PhotoCommentResource', type: :feature do
  let!(:post) { create :post, user: admin }
  let!(:comments) { create_list :comment, 20, commentable: post }
  let!(:comment) { create :comment }

  describe 'tests' do
    it 'if have diferent fields from original comment resource' do
      visit_page

      expect(page).to have_text('Photo comments')
      expect(page).to have_text('Tiny name')
      expect(page).to have_text('Photo')
      expect(page).to have_link('Create new photo comment')
      expect(page).to have_link('Attach photo comment')

      expect(page).not_to have_text('Posted at')
      expect(page).not_to have_text('Create new comment')
    end

    it 'if create new photo comment persist and attach' do
      visit_page

      click_on 'Create new photo comment'

      expect(page).to have_current_path "/admin/resources/photo_comments/new?via_relation=commentable&via_relation_class=Post&via_resource_id=#{post.id}"

      fill_in 'comment_body', with: "I'm a photo comment!"

      click_on 'Save'
      wait_for_loaded

      expect(current_path).to eql "/admin/resources/posts/#{post.id}"

      comment = post.comments.last

      visit "/admin/resources/photo_comments/#{comment.id}"

      expect(page).to have_text("I'm a photo comment!")
    end

    it 'if have photo comment resource controls' do
      visit_page

      expect(page).to have_selector "[title='Edit photo comment']"
      expect(page).to have_selector "[title='View photo comment']"
      expect(page).to have_selector "[title='Delete photo comment']"
    end

    it 'if attach persist' do
      visit_page

      click_on 'Attach photo comment'

      expect(page).to have_text 'Choose photo comment'
      expect(page).to have_select 'fields_related_id'

      select comment.tiny_name, from: 'fields_related_id'

      click_on 'Attach'
      expect(page).to have_text 'Photo comment attached.'
      expect(page).to have_text comment.tiny_name
    end
  end
end

def visit_page
  visit "admin/resources/posts/#{post.id}/comments?turbo_frame=has_many_field_show_photo_comments"

  expect(current_path).to eql "/admin/resources/posts/#{post.id}/comments"
end
