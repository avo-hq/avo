require 'rails_helper'

RSpec.describe "GravatarFields", type: :system do
  describe 'with regular input' do
    let!(:user) { create :user }
    # TODO think about testing this
    context 'index' do
      it 'displays the users avatar' do
        visit '/avocado/resources/users'

        expect(page).to have_text user.email
      end
    end

    context 'show' do
      it 'displays the users name' do
        visit "/avocado/resources/users/#{user.id}"

        expect(page).to have_text user.email
      end
    end
  end
end
