require 'rails_helper'

RSpec.describe 'textarea', type: :feature do
  context 'show' do
    let(:url) { "/avo/resources/teams/#{team.id}" }

    subject { visit url; find_field_element('description') }

    describe 'with value' do
      let(:description) { 'Lorem ipsum' }
      let!(:team) { create :team, description: description }

      it { is_expected.to have_text description }
    end

    describe 'without value' do
      let!(:team) { create :team, description: nil }

      it { is_expected.to have_text empty_dash }
    end
  end

  context 'edit' do
    let(:url) { "/avo/resources/teams/#{team.id}/edit" }

    subject { visit url; find_field_element('description') }

    describe 'with value' do
      let(:description) { 'Lorem ipsum' }
      let(:new_description) { 'Lorem ipsum nostrum' }
      let!(:team) { create :team, description: description }

      it { is_expected.to have_field type: 'textarea', id: 'team_description', placeholder: 'Description', text: description }

      it 'changes the description' do
        visit url

        expect(page).to have_field type: 'textarea', id: 'team_description', placeholder: 'Description', text: description

        fill_in 'team_description', with: new_description

        click_on 'Save'

        expect(current_path).to eql "/avo/resources/teams/#{team.id}"
        expect(page).to have_text new_description
      end

      it 'cleares the description' do
        visit url

        expect(page).to have_field type: 'textarea', id: 'team_description', placeholder: 'Description', text: description

        fill_in 'team_description', with: nil

        click_on 'Save'

        expect(current_path).to eql "/avo/resources/teams/#{team.id}"
        expect(find_field_value_element('description')).to have_text empty_dash
      end
    end

    describe 'without value' do
      let(:new_description) { 'Lorem ipsum nostrum' }
      let!(:team) { create :team, description: nil }

      it { is_expected.to have_field type: 'textarea', id: 'team_description', placeholder: 'Description', text: nil }

      it 'sets the description' do
        visit url

        expect(page).to have_field type: 'textarea', id: 'team_description', placeholder: 'Description', text: nil

        fill_in 'team_description', with: new_description

        click_on 'Save'

        expect(current_path).to eql "/avo/resources/teams/#{team.id}"
        expect(page).to have_text new_description
      end
    end
  end
end
