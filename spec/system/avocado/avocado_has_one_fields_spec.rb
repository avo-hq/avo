require 'rails_helper'

RSpec.describe 'HasOneField', type: :system do
  let!(:user) { create :user }

  subject { visit url; page }

  context 'index' do
    let(:url) { '/avocado/resources/teams' }

    describe 'with a related user' do
      let!(:team) { create :team, admin: user }

      it { is_expected.to have_text user.name }
    end

    describe 'without a related user' do
      let!(:team) { create :team }

      it { is_expected.to have_text '-' }
    end
  end

  context 'show' do
    let(:url) { "/avocado/resources/teams/#{team.id}" }

    describe 'with user attached' do
      let!(:team) { create :team, admin: user }

      it { is_expected.to have_link user.name, href: "/avocado/resources/users/#{user.id}" }
    end

    describe 'without user attached' do
      let!(:team) { create :team }

      it { is_expected.to have_text '-' }
    end
  end

  context 'edit' do
    let(:url) { "/avocado/resources/teams/#{team.id}/edit" }

    describe 'without user attached' do
      let!(:team) { create :team }

      it { is_expected.to have_select 'admin', selected: '-' }

      it 'changes the admin' do
        visit url
        expect(page).to have_select 'admin', selected: '-'

        select user.name, from: 'admin'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/teams/#{team.id}"
        expect(page).to have_link user.name, href: "/avocado/resources/users/#{user.id}"
      end
    end

    describe 'with user attached' do
      let!(:team) { create :team, admin: user }
      let!(:second_user) { create :user }

      it { is_expected.to have_select 'admin', selected: user.name }

      it 'changes the user' do
        visit url
        expect(page).to have_select 'admin', selected: user.name

        select second_user.name, from: 'admin'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/teams/#{team.id}"
        expect(page).to have_link second_user.name, href: "/avocado/resources/users/#{second_user.id}"
      end

      it 'nullifies the user' do
        visit url
        expect(page).to have_select 'admin', selected: user.name

        select '-', from: 'admin'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/teams/#{team.id}"
        expect(find_field_value_element('admin')).to have_text '-'
      end
    end
  end
end
