require 'rails_helper'

RSpec.describe 'DefaultField', type: :system do
  describe 'with a default value (team - description)' do

    context 'create' do
      it 'checks presence of default team description' do
        visit '/avocado/resources/teams/new'
        wait_for_loaded

        expect(find("[field-id='description'] [data-slot='value'] textarea").value).to have_text 'This team is wonderful!'
      end

      it 'saves team and checks for default team description value' do
        visit '/avocado/resources/teams/new'
        wait_for_loaded

        fill_in 'name', with: 'Joshua Josh'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to have_text '/avocado/resources/teams/'
        expect(find_field_element(:description)).to have_text 'This team is wonderful!'
      end
    end
  end

  describe 'with a computable default value (team_membership - level)' do
    let!(:user) { create :user, first_name: 'Mihai', last_name: 'Marin' }
    let!(:team) { create :team, name: 'Apple' }

    context 'create' do
      it 'checks presence of default team membership level' do
        visit '/avocado/resources/team_memberships/new'
        wait_for_loaded

        if Time.now.hour < 12
          expect(find_field_element(:level)).to have_text 'Advanced'
        else
          expect(find_field_element(:level)).to have_text 'Beginner'
        end
      end

      it 'saves team membership and checks for default team membership level value' do
        visit '/avocado/resources/team_memberships/new'
        wait_for_loaded

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
