require 'rails_helper'

RSpec.describe 'NullableField', type: :system do
  describe 'without input (specifying null_values: ["", "0", "null", "nil"])' do
    let!(:team) { create :team, description: nil }

    context 'show' do
      it 'displays the teams empty description (dash)' do
        visit "/avo/resources/teams/#{team.id}"

        expect(find_field_value_element('description')).to have_text empty_dash
      end
    end

    context 'edit' do
      it 'has the teams description empty' do
        visit "/avo/resources/teams/#{team.id}/edit"

        expect(find_field('description').value).to eq ''
      end
    end
  end

  describe 'with regular input (specifying null_values: ["", "0", "null", "nil"])' do
    let!(:team) { create :team, description: 'descr' }

    context 'edit' do
      it 'has the teams description prefilled' do
        visit "/avo/resources/teams/#{team.id}/edit"

        expect(find_field('description').value).to eq 'descr'
      end
      it 'changes the teams description to null ("" - empty string)' do
        visit "/avo/resources/teams/#{team.id}/edit"

        fill_in 'description', with: ''
        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/teams/#{team.id}"
        expect(find_field_value_element('description')).to have_text empty_dash
      end

      it 'changes the teams description to null ("0")' do
        visit "/avo/resources/teams/#{team.id}/edit"

        fill_in 'description', with: '0'
        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/teams/#{team.id}"
        expect(find_field_value_element('description')).to have_text empty_dash
      end

      it 'changes the teams description to null ("nil")' do
        visit "/avo/resources/teams/#{team.id}/edit"

        fill_in 'description', with: 'nil'
        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/teams/#{team.id}"
        expect(find_field_value_element('description')).to have_text empty_dash
      end

      it 'changes the teams description to null ("null")' do
        visit "/avo/resources/teams/#{team.id}/edit"

        fill_in 'description', with: 'null'
        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/teams/#{team.id}"
        expect(find_field_value_element('description')).to have_text empty_dash
      end
    end
  end

  describe 'without input (without specifying null_values)' do
    let!(:project) { create :project, status: nil }

    context 'show' do
      it 'displays the projects empty status (dash)' do
        visit "/avo/resources/project/#{project.id}"

        expect(find_field_value_element('status')).to have_text empty_dash
      end
    end

    context 'edit' do
      it 'has the projects status empty' do
        visit "/avo/resources/projects/#{project.id}/edit"

        expect(find_field('status').value).to eq ''
      end
    end
  end

  describe 'with regular input (without specifying null_values)' do
    let!(:project) { create :project, status: 'rejected' }

    context 'edit' do
      it 'has the projects status prefilled' do
        visit "/avo/resources/projects/#{project.id}/edit"

        expect(find_field('status').value).to eq 'rejected'
      end
      it 'changes the projects status to null ("" - empty string)' do
        visit "/avo/resources/projects/#{project.id}/edit"

        fill_in 'status', with: ''
        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"
        expect(find_field_value_element('status')).to have_text empty_dash
      end
    end
  end
end
