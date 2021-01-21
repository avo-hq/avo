require 'rails_helper'

RSpec.describe 'textarea', type: :feature do
  context 'show' do
    let(:url) { "/avo/resources/posts/#{post.id}" }

    subject { visit url; find_field_element('body') }

    describe 'with value' do
      let(:body) { 'Lorem ipsum' }
      let!(:post) { create :post, body: body }

      it { is_expected.to have_text body }
    end

    describe 'without value' do
      let!(:post) { create :post, body: nil }

      it { is_expected.to have_text empty_dash }
    end
  end

  context 'edit' do
    let(:url) { "/avo/resources/posts/#{post.id}/edit" }

    subject { visit url; find_field_element('body') }

    describe 'with value' do
      let(:body) { 'Lorem ipsum' }
      let(:new_body) { 'Lorem ipsum nostrum' }
      let!(:post) { create :post, body: body }

      it { is_expected.to have_field type: 'textarea', id: 'post_body', placeholder: 'Body', text: body }

      it 'changes the body' do
        visit url

        expect(page).to have_field type: 'textarea', id: 'post_body', placeholder: 'Body', text: body

        fill_in 'post_body', with: new_body

        click_on 'Save'

        expect(current_path).to eql "/avo/resources/posts/#{post.id}"
        expect(page).to have_text new_body
      end

      it 'cleares the body' do
        visit url

        expect(page).to have_field type: 'textarea', id: 'post_body', placeholder: 'Body', text: body

        fill_in 'post_body', with: nil

        click_on 'Save'

        expect(current_path).to eql "/avo/resources/posts/#{post.id}"
        expect(find_field_value_element('body')).to have_text empty_dash
      end
    end

    describe 'without value' do
      let(:new_body) { 'Lorem ipsum nostrum' }
      let!(:post) { create :post, body: nil }

      it { is_expected.to have_field type: 'textarea', id: 'post_body', placeholder: 'Body', text: nil }

      it 'sets the body' do
        visit url

        expect(page).to have_field type: 'textarea', id: 'post_body', placeholder: 'Body', text: nil

        fill_in 'post_body', with: new_body

        click_on 'Save'

        expect(current_path).to eql "/avo/resources/posts/#{post.id}"
        expect(page).to have_text new_body
      end
    end
  end
end
