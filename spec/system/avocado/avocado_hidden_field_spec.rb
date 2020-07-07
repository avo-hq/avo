require 'rails_helper'

RSpec.describe 'HiddenField', type: :system do
  describe 'without input' do
    let!(:user) { create :user }

    context 'edit' do
      it 'has the hidden field empty' do
        visit "/avocado/resources/users/#{user.id}/edit"

        expect(find("[field-id='group_id']", visible: false).find("input[type='hidden']", visible: false).value).to eq ""
      end
    end
  end

  describe 'with regular input' do
    let!(:user) { create :user, group_id: 10 }

    context 'edit' do
      it 'has the hidden field' do
        visit "/avocado/resources/users/#{user.id}/edit"

        expect(find("[field-id='group_id']", visible: false).find("input[type='hidden']", visible: false).value).to eq "10"
      end
    end
  end
end
