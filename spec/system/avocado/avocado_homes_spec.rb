require 'rails_helper'

RSpec.describe 'Posts', type: :system do
  describe 'index' do
    before do
      user = User.create!(name: 'John', email: 'dasdad@dasd.cc', password: 'qweqwe')
      post = Post.create(name: 'Project 1', user: user)
      post.save!
    end

    it 'Shows the projects' do
      visit '/avocado'

      click_link 'Post'

      expect(page).to have_text('Project 1')
    end
  end
end
