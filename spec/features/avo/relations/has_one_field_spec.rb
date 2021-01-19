require 'rails_helper'

RSpec.describe 'HasOneField', type: :feature do
  # let!(:user) { create :user }

  subject { visit url; page }

  context 'index' do
    let(:url) { '/avo/resources/teams' }

    describe 'with a related user' do
      let!(:team) { create :team, admin: admin }

      it { is_expected.to have_text admin.name }
    end
  end

  context 'show' do
    let(:url) { "/avo/resources/teams/#{team.id}" }

    describe 'with user attached' do
      let!(:team) { create :team, admin: admin }

      it { is_expected.to have_link admin.name, href: "/avo/resources/users/#{admin.id}?via_resource_id=#{team.id}&via_resource_name=teams" }
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

      it { is_expected.to have_select 'team_admin', selected: nil, options: ['Choose an option', admin.name] }

      it 'changes the admin' do
        visit url
        expect(page).to have_select 'team_admin', selected: nil, options: ['Choose an option', admin.name]

        select admin.name, from: 'team_admin'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/teams/#{team.id}"
        expect(page).to have_link admin.name, href: "/avo/resources/users/#{admin.id}?via_resource_id=#{team.id}&via_resource_name=teams"
      end
    end

    describe 'with user attached' do
      let!(:team) { create :team, admin: admin }
      let!(:second_user) { create :user }

      it { is_expected.to have_select 'team_admin', selected: admin.name }

      it 'changes the user' do
        visit url
        expect(page).to have_select 'team_admin', selected: admin.name

        select second_user.name, from: 'team_admin'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/teams/#{team.id}"
        expect(page).to have_link second_user.name, href: "/avo/resources/users/#{second_user.id}?via_resource_id=#{team.id}&via_resource_name=teams"
      end

      it 'nullifies the user' do
        visit url
        expect(page).to have_select 'team_admin', selected: admin.name

        select 'Choose an option', from: 'team_admin'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/teams/#{team.id}"
        expect(find_field_value_element('admin')).to have_text empty_dash
      end
    end
  end
end
