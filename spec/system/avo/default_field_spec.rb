require 'rails_helper'

RSpec.describe 'DefaultField', type: :system do
  describe 'with a default value (team - description)' do

    context 'create' do
      it 'checks presence of default team description' do
        visit '/avo/resources/teams/new'
        wait_for_loaded

        expect(find("[field-id='description'] [data-slot='value'] textarea").value).to have_text 'This team is wonderful!'
      end

      it 'saves team and checks for default team description value' do
        visit '/avo/resources/teams/new'
        wait_for_loaded

        expect(Team.count).to eql 0

        fill_in 'name', with: 'Joshua Josh'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/teams/#{Team.last.id}"
        expect(find_field_element(:description)).to have_text 'This team is wonderful!'
      end
    end
  end

  describe 'with a computable default value (team_membership - level)' do
    let!(:user) { create :user, first_name: 'Mihai', last_name: 'Marin' }
    let!(:team) { create :team, name: 'Apple' }

    context 'create' do
      it 'checks presence of default team membership level' do
        visit '/avo/resources/team_memberships/new'
        wait_for_loaded

        if Time.now.hour < 12
          expect(find_field_element(:level)).to have_text 'Advanced'
        else
          expect(find_field_element(:level)).to have_text 'Beginner'
        end
      end

      it 'saves team membership and checks for default team membership level value' do
        visit '/avo/resources/team_memberships/new'
        wait_for_loaded

        expect(TeamMembership.count).to eql 0

        select 'Mihai Marin', from: :user
        select 'Apple', from: :team

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/team_memberships/#{TeamMembership.last.id}"

        if Time.now.hour < 12
          expect(find_field_element(:level)).to have_text 'advanced'
        else
          expect(find_field_element(:level)).to have_text 'beginner'
        end

        expect(find_field_element(:user)).to have_text 'Mihai Marin'
        expect(find_field_element(:team)).to have_text 'Apple'
      end
    end
  end
end
