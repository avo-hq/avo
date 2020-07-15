require 'rails_helper'

RSpec.describe 'NullableField', type: :system do
  describe 'without input (specifying null_values: ["", "0", "null", "nil"])' do
    let!(:team) { create :team, description: nil }

    context 'show' do
      it 'displays the teams empty description (dash)' do
        visit "/avocado/resources/team/#{team.id}"

        expect(find_field_value_element('description')).to have_text empty_dash
      end
    end

    context 'edit' do
      it 'has the teams description empty' do
        visit "/avocado/resources/teams/#{team.id}/edit"

        expect(find_field('description').value).to eq ''
      end
    end
  end

  describe 'with regular input (specifying null_values: ["", "0", "null", "nil"])' do
    let!(:team) { create :team, description: 'descr' }

    context 'edit' do
      it 'has the teams description prefilled' do
        visit "/avocado/resources/teams/#{team.id}/edit"

        expect(find_field('description').value).to eq 'descr'
      end
      it 'changes the teams description to null ("" - empty string)' do
        visit "/avocado/resources/teams/#{team.id}/edit"

        fill_in 'description', with: ''
        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/teams/#{team.id}"
        expect(find_field_value_element('description')).to have_text empty_dash
      end

      it 'changes the teams description to null ("0")' do
        visit "/avocado/resources/teams/#{team.id}/edit"

        fill_in 'description', with: '0'
        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/teams/#{team.id}"
        expect(find_field_value_element('description')).to have_text empty_dash
      end

      it 'changes the teams description to null ("nil")' do
        visit "/avocado/resources/teams/#{team.id}/edit"

        fill_in 'description', with: 'nil'
        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/teams/#{team.id}"
        expect(find_field_value_element('description')).to have_text empty_dash
      end

      it 'changes the users description to null ("null")' do
        visit "/avocado/resources/teams/#{team.id}/edit"

        fill_in 'description', with: 'null'
        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/teams/#{team.id}"
        expect(find_field_value_element('description')).to have_text empty_dash
      end
    end
  end

  describe 'without input (without specifying null_values)' do
    let!(:post) { create :post, body: nil }

    context 'show' do
      it 'displays the posts empty body (dash)' do
        visit "/avocado/resources/post/#{post.id}"

        expect(find_field_value_element('body')).to have_text empty_dash
      end
    end

    context 'edit' do
      it 'has the posts body empty' do
        visit "/avocado/resources/posts/#{post.id}/edit"

        expect(find_field('body').value).to eq ''
      end
    end
  end

  describe 'with regular input (without specifying null_values)' do
    let!(:post) { create :post, body: 'Story begins here!' }

    context 'edit' do
      it 'has the posts body prefilled' do
        visit "/avocado/resources/posts/#{post.id}/edit"

        expect(find_field('body').value).to eq 'Story begins here!'
      end
      it 'changes the posts body to null ("" - empty string)' do
        visit "/avocado/resources/posts/#{post.id}/edit"

        fill_in 'body', with: ''
        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/posts/#{post.id}"
        expect(find_field_value_element('body')).to have_text empty_dash
      end
    end
  end
end
