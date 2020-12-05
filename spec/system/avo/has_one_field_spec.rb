require 'rails_helper'

RSpec.describe 'HasOneField', type: :system do
  let!(:user) { create :user }

  subject { visit url; page }

  context 'index' do
    let(:url) { '/avo/resources/teams' }

    describe 'with a related user' do
      let!(:team) { create :team, admin: user }

      it { is_expected.to have_text user.name }
    end

    describe 'without a related user' do
      let!(:team) { create :team }

      it 'looks for team without related user' do
        visit url
        find('[data-button="resource-filters"]').click

        uncheck 'Has Members'
        wait_for_loaded

        expect(page).to have_text empty_dash

      end
    end
  end

  context 'show' do
    let(:url) { "/avo/resources/teams/#{team.id}" }

    describe 'with user attached' do
      let!(:team) { create :team, admin: user }

      it { is_expected.to have_link user.name, href: "/avo/resources/users/#{user.id}" }
    end

    describe 'without user attached' do
      let!(:team) { create :team }

      it { is_expected.to have_text empty_dash }
    end
  end

  context 'edit' do
    let(:url) { "/avo/resources/teams/#{team.id}/edit" }

    describe 'without user attached' do
      let!(:team) { create :team }

      it { is_expected.to have_select 'admin', selected: 'Choose an option' }

      it 'changes the admin' do
        visit url
        expect(page).to have_select 'admin', selected: 'Choose an option'

        select user.name, from: 'admin'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/teams/#{team.id}"
        expect(page).to have_link user.name, href: "/avo/resources/users/#{user.id}"
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

        expect(current_path).to eql "/avo/resources/teams/#{team.id}"
        expect(page).to have_link second_user.name, href: "/avo/resources/users/#{second_user.id}"
      end

      it 'nullifies the user' do
        visit url
        expect(page).to have_select 'admin', selected: user.name

        select 'Choose an option', from: 'admin'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/teams/#{team.id}"
        expect(find_field_value_element('admin')).to have_text empty_dash
      end
    end
  end
end
