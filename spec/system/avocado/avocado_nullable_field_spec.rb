require 'rails_helper'

RSpec.describe 'NullableField', type: :system do
  describe 'without input' do
    let!(:user) { create :user, description: nil }

    context 'show' do
      it 'displays the users empty description (dash)' do
        visit "/avocado/resources/users/#{user.id}"

        expect(find_field_value_element('description')).to have_text empty_dash
      end
    end

    context 'edit' do
      it 'has the users description empty' do
        visit "/avocado/resources/users/#{user.id}/edit"

        expect(find_field('description').value).to eq ''
      end
    end
  end

  describe 'with regular input' do
    let!(:user) { create :user, description: 'descr' }

    context 'edit' do
      it 'has the users description prefilled' do
        visit "/avocado/resources/users/#{user.id}/edit"

        expect(find_field('description').value).to eq 'descr'
      end
      it 'changes the users description to null ("" - empty string)' do
        visit "/avocado/resources/users/#{user.id}/edit"

        fill_in 'description', with: ''
        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/users/#{user.id}"
        expect(find_field_value_element('description')).to have_text empty_dash
      end

      it 'changes the users description to null ("0")' do
        visit "/avocado/resources/users/#{user.id}/edit"

        fill_in 'description', with: '0'
        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/users/#{user.id}"
        expect(find_field_value_element('description')).to have_text empty_dash
      end

      it 'changes the users description to null ("nil")' do
        visit "/avocado/resources/users/#{user.id}/edit"

        fill_in 'description', with: 'nil'
        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/users/#{user.id}"
        expect(find_field_value_element('description')).to have_text empty_dash
      end

      it 'changes the users description to null ("null")' do
        visit "/avocado/resources/users/#{user.id}/edit"

        fill_in 'description', with: 'null'
        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/users/#{user.id}"
        expect(find_field_value_element('description')).to have_text empty_dash
      end
    end
  end
end
