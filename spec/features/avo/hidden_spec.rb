require 'rails_helper'

RSpec.describe 'hidden', type: :feature do

  context 'edit' do
    let(:url) { "/avo/resources/users/#{user.id}/edit" }

    describe 'without input' do
      let!(:user) { create :user }
      it 'has the hidden field empty' do
        visit url

        expect(find("[data-field-id='team_id'] input[type='hidden']", visible: false).value).to be_nil
      end
    end

    describe 'with input' do
      let!(:user) { create :user, team_id: 10 }

      it 'has the hidden field' do
        visit "/avo/resources/users/#{user.id}/edit"

        expect(find("[data-field-id='team_id'] input[type='hidden']", visible: false).value).to eq '10'
      end
    end
  end

  context 'create' do
    let(:url) { '/avo/resources/users/new' }

    it 'has the hidden field prefilled with default' do
      visit url

      # expect(find("[data-field-id='team_id'] input[type='hidden']", visible: false).value).to eq 0
    end
  end

end
