require "rails_helper"

RSpec.feature "external_link", type: :feature do
  let!(:post) { create :post }

  describe "external_link" do
    it "on show" do
      visit avo.resources_post_path(post)

      find("[target='_blank'][href='/posts/#{post.to_param}']").click

      expect(current_path).to eq "/posts/#{post.to_param}"
      expect(page).to have_text("Find me in app/views/posts/show.html.erb")
    end

    it "on edit" do
      visit avo.edit_resources_post_path(post)

      find("[target='_blank'][href='/posts/#{post.to_param}']").click

      expect(current_path).to eq "/posts/#{post.to_param}"
      expect(page).to have_text("Find me in app/views/posts/show.html.erb")
    end
  end
end
