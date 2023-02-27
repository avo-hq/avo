# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Hide search input', type: :feature do
  let!(:five_spouses) { create_list :spouse, 5 }
  let!(:person_with_five_spouses) { create :person, spouses: five_spouses }
  let!(:user) { create :user }
  let!(:team) { create :team }
  let!(:team_membership) { team.team_members << user }

  describe 'with value' do
    it 'true, finds only global search' do
      visit_person_page

      expect(page).to have_text('Spouses')
      expect(page).to have_text('Name')
      expect(page).to have_link('Create new spouse')
      expect(page).to have_link('Attach spouse')

      expect(page).to have_selector('[data-controller="search"]').once
    end

    it 'false, finds global and association search' do
      visit_team_page

      expect(page).to have_text('Team memberz')
      expect(page).to have_text('Avatar')
      expect(page).to have_text('First name')
      expect(page).to have_text('Last name')
      expect(page).to have_link('Create new team member')
      expect(page).to have_link('Attach team member')

      expect(page).to have_selector('[data-controller="search"]').twice
    end
  end
end

def visit_person_page
  visit "admin/resources/people/#{person_with_five_spouses.id}/spouses?turbo_frame=has_many_field_show_spouses"

  expect(current_path).to eql "/admin/resources/people/#{person_with_five_spouses.id}/spouses"
end

def visit_team_page
  visit "admin/resources/teams/#{team.id}/team_members?turbo_frame=has_many_field_show_team_members"

  expect(current_path).to eql "/admin/resources/teams/#{team.id}/team_members"
end
