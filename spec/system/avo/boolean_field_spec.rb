require "rails_helper"

RSpec.describe "BooleanField", type: :system do
  describe "with regular input" do
    let!(:post) { create :post, name: "My Post", is_featured: nil }

    context "show" do
      it "displays the post values" do
        visit "/admin/resources/posts/#{post.id}"

        expect(page).to have_text "IS FEATURED"

        expect(find_field_value_element("is_featured")).to have_text empty_dash
      end
    end
  end
end
