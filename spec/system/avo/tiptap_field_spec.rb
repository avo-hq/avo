require 'rails_helper'

RSpec.describe 'TiptapField', type: :system do
  describe 'without value' do
    let!(:post) { create :post, body: '' }

    context 'show' do
      it 'displays the posts empty body (dash)' do
        visit "/admin/resources/posts/#{post.id}"

        expect(find_field_element('body')).to have_text empty_dash
      end
    end

    context 'edit' do
      it 'has the posts body label and empty tiptap editor and placeholder' do
        visit "/admin/resources/posts/#{post.id}/edit"

        body_element = find_field_element('body')

        expect(body_element).to have_text 'BODY'

        expect(find('#tiptap_post_body_editor', visible: false)[:placeholder]).to have_text('Enter text')
        expect(find('#tiptap_post_body_editor', visible: false)).to have_text('')
      end

      it 'change the posts body text' do
        visit "/admin/resources/posts/#{post.id}/edit"

        fill_in_tiptap_editor 'tiptap_post_body', with: 'Works for us!!!'

        save

        click_on 'Show content'

        expect(find_field_value_element('body')).to have_text 'Works for us!!!'
      end
    end
  end

  describe 'with regular value' do
    let!(:body) { '<div>Example tiptap text.</div>' }
    let!(:post) { create :post, body: }

    context 'show' do
      it 'displays the posts body' do
        visit "/admin/resources/posts/#{post.id}"

        click_on 'Show content'

        expect(find_field_value_element('body')).to have_text ActionView::Base.full_sanitizer.sanitize(body)
      end
    end

    context 'edit' do
      it 'has the posts body label' do
        visit "/admin/resources/posts/#{post.id}/edit"

        body_element = find_field_element('body')

        expect(body_element).to have_text 'BODY'
      end

      it 'has filled simple text in tiptap editor' do
        visit "/admin/resources/posts/#{post.id}/edit"

        expect(find('#tiptap_post_body', visible: false).value).to eq(body)
      end

      it 'change the posts body tiptap to another simple text value' do
        visit "/admin/resources/posts/#{post.id}/edit"

        fill_in_tiptap_editor 'tiptap_post_body', with: 'New example!'

        save
        click_on 'Show content'

        expect(find_field_value_element('body')).to have_text 'New example!'
      end
    end
  end
end

def fill_in_tiptap_editor(id, with:)
  find("##{id}_editor").find('.ProseMirror').click.set(with)
end
