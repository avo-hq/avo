require 'rails_helper'

RSpec.describe 'BelongsToField', type: :system do
  let!(:user) { create :user }

  subject { visit url; page }

  context 'index' do
    let(:url) { '/avocado/resources/posts' }

    describe 'with a related user' do
      let!(:post) { create :post, user: user }

      it { is_expected.to have_text user.name }
    end

    describe 'without a related user' do
      let!(:post) { create :post }

      it { is_expected.to have_text empty_dash }
    end
  end

  context 'show' do
    let(:url) { "/avocado/resources/posts/#{post.id}" }

    describe 'with user attached' do
      let!(:post) { create :post, user: user }

      it { is_expected.to have_link user.name, href: "/avocado/resources/users/#{user.id}" }
    end

    describe 'without user attached' do
      let!(:post) { create :post }

      it { is_expected.to have_text empty_dash }
    end
  end

  context 'edit' do
    let(:url) { "/avocado/resources/posts/#{post.id}/edit" }

    describe 'without user attached' do
      let!(:post) { create :post }

      it { is_expected.to have_select 'user', selected: empty_dash }

      it 'changes the user' do
        visit url
        expect(page).to have_select 'user', selected: empty_dash

        select user.name, from: 'user'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/posts/#{post.id}"
        expect(page).to have_link user.name, href: "/avocado/resources/users/#{user.id}"
      end
    end

    describe 'with user attached' do
      let!(:post) { create :post, user: user }
      let!(:second_user) { create :user }

      it { is_expected.to have_select 'user', selected: user.name }

      it 'changes the user' do
        visit url
        expect(page).to have_select 'user', selected: user.name

        select second_user.name, from: 'user'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/posts/#{post.id}"
        expect(page).to have_link second_user.name, href: "/avocado/resources/users/#{second_user.id}"
      end

      it 'nullifies the user' do
        visit url
        expect(page).to have_select 'user', selected: user.name

        select empty_dash, from: 'user'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/posts/#{post.id}"
        expect(find_field_value_element('user')).to have_text empty_dash
      end
    end
  end
end
