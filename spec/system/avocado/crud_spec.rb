require 'rails_helper'

RSpec.describe 'Posts', type: :system do
  describe 'index' do
    let!(:user) { create :user }
    let!(:post) { create :post, user: user }

    it 'Shows the projects' do
      visit '/avocado'

      click_link 'Posts'

      expect(page).to have_text(post.name)
    end
  end
end
