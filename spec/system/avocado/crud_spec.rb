require 'rails_helper'

RSpec.describe 'Posts', type: :system do
  describe 'index' do
    before do
      driven_by :selenium_chrome_headless

      user = User.create!(name: 'John', email: 'dasdad@dasd.cc', password: 'qweqwe', age: 18, description: 'Hey there')
      post = Post.create(name: 'Project 1', user: user)
      post.save!
    end

    it 'Shows the projects' do
      visit '/avocado'

      click_link 'Posts'

      expect(page).to have_text('Project 1')
    end
  end
end
