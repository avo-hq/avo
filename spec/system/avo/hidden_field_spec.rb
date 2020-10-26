require 'rails_helper'
WebMock.disable_net_connect!(allow_localhost: true, allow: 'chromedriver.storage.googleapis.com')

RSpec.describe 'HiddenField', type: :system do
  describe 'without input' do
    let!(:user) { create :user }

    context 'edit' do
      it 'has the hidden field empty' do
        visit "/avo/resources/users/#{user.id}/edit"

        expect(find("[field-id='team_id'] input[type='hidden']", visible: false).value).to be_empty
      end
    end
  end

  describe 'with regular input' do
    let!(:user) { create :user, team_id: 10 }

    context 'edit' do
      it 'has the hidden field' do
        visit "/avo/resources/users/#{user.id}/edit"

        expect(find("[field-id='team_id'] input[type='hidden']", visible: false).value).to eq '10'
      end
    end
  end
end
