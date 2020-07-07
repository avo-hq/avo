require 'rails_helper'

RSpec.describe 'HiddenField', type: :system do
  describe 'without input' do
    let!(:user) { create :user }

    context 'edit' do
      it 'has the hidden field empty' do
        visit "/avocado/resources/users/#{user.id}/edit"

        expect(find("[field-id='group_id'] input[type='hidden']", visible: false).value).to be_empty
      end
    end
  end

  describe 'with regular input' do
    let!(:user) { create :user, group_id: 10 }

    context 'edit' do
      it 'has the hidden field' do
        visit "/avocado/resources/users/#{user.id}/edit"

        expect(find("[field-id='group_id'] input[type='hidden']", visible: false).value).to eq '10'
      end

      it 'changes the hidden field' do
        visit "/avocado/resources/users/#{user.id}/edit"

        user.group_id = 11
        user.save

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/users/#{user.id}"

        visit "/avocado/resources/users/#{user.id}/edit"
        expect(find("[field-id='group_id'] input[type='hidden']", visible: false).value).to eq '10'
      end
    end
  end
end
