# require 'rails_helper'

# RSpec.feature 'AButton', type: :system do
#   describe 'with to attribute' do
#     it 'navigates to the requested path' do
#       visit '/admin/resources/posts'

#       click_on 'Create new post'
#       wait_for_loaded

#       expect(current_path).to eq '/admin/resources/posts/new'
#     end
#   end

#   describe 'with @click attribute' do
#     let!(:post) { create :post }

#     it 'navigates to the requested path' do
#       visit "/admin/resources/posts/#{post.id}"

#       click_on 'Delete'
#       click_on 'Confirm'
#       wait_for_loaded

#       expect(current_path).to eq '/admin/resources/posts'
#     end
#   end
# end
