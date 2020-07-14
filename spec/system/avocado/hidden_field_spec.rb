require 'rails_helper'

RSpec.describe 'HiddenField', type: :system do
  describe 'without input' do
    let!(:user) { create :user }

    context 'edit' do
      it 'has the hidden field empty' do
        visit "/avocado/resources/users/#{user.id}/edit"

        expect(find("[field-id='team_id'] input[type='hidden']", visible: false).value).to be_empty
      end
    end
  end

  describe 'with regular input' do
    let!(:user) { create :user, team_id: 10 }

    context 'edit' do
      it 'has the hidden field' do
        visit "/avocado/resources/users/#{user.id}/edit"

        expect(find("[field-id='team_id'] input[type='hidden']", visible: false).value).to eq '10'
      end
    end
  end
end
