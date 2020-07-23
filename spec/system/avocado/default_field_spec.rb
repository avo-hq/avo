require 'rails_helper'

RSpec.describe 'DefaultField', type: :system do
  describe 'with a default value (team - name)' do

    context 'create' do
      it 'checks presence of default team name' do
        visit '/avocado/resources/teams/new'

        expect(find_field_element(:name)).to have_text 'Inc.'
      end

      it 'saves team and checks for default team name value' do
        visit '/avocado/resources/teams/new'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to have_text '/avocado/resources/teams/'
        expect(find_field_element(:name)).to have_text 'Inc.'
      end
    end
  end

  describe 'with a computable default value (team_membership - level)' do
    let!(:user) { create :user, first_name: 'Mihai', last_name: 'Marin' }
    let!(:team) { create :team, name: 'Apple' }

    context 'create' do
      it 'checks presence of default team membership level' do
        visit '/avocado/resources/team_memberships/new'

        if Time.now.hour < 12
          expect(find_field_element(:level)).to have_text 'Advanced'
        else
          expect(find_field_element(:level)).to have_text 'Beginner'
        end
      end

      it 'saves team membership and checks for default team membership level value' do
        visit '/avocado/resources/team_memberships/new'

        select 'Mihai Marin', from: :user
        select 'Apple', from: :team

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to have_text '/avocado/resources/team_memberships/'

        if Time.now.hour < 12
          expect(find_field_element(:level)).to have_text 'Advanced'
        else
          expect(find_field_element(:level)).to have_text 'Beginner'
        end

        expect(find_field_element(:user)).to have_text 'Mihai Marin'
        expect(find_field_element(:team)).to have_text 'Apple'
      end
    end
  end
end
