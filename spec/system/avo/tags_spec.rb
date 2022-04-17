require 'rails_helper'

RSpec.describe "Tags", type: :system do
  let!(:post) { create :post }

  describe "acts_as_taggable" do
    context "show" do
      let(:path) {"/admin/resources/posts/#{post.id}"}

      it "shows empty state" do
        visit path

        expect(find_field_value_element("tags")).to have_text empty_dash
      end

      it "shows filled state" do
        post.tag_list = ['some', 'tags', 'here', 'and', 'there']
        post.save

        visit path

        expect(find_field_value_element("tags")).not_to have_text empty_dash
        expect(find_field_value_element("tags")).not_to have_text 'some tags here and there'
      end
    end

    context "index" do
      let(:path) {"/admin/resources/posts?view_type=table"}

      it "shows empty state" do
        visit path

        expect(field_element_by_resource_id("tags", post.id)).to have_text empty_dash
      end

      it "shows filled state" do
        post.tag_list = ['some', 'tags', 'here', 'and', 'there']
        post.save

        visit path

        field_element = field_element_by_resource_id("tags", post.id)

        expect(field_element).not_to have_text empty_dash
        expect(field_element).not_to have_text 'some tags here ...'

        field_element.find('[data-target="tag-component"]', text: '...').hover
        expect(page).to have_text '2 more items'
      end
    end

    context "edit" do
      let(:path) {"/admin/resources/posts/#{post.id}/edit"}
      let(:tag_input) {tags_element(find_field_value_element("tags"))}

      it "shows empty state" do
        visit path

        expect(find_field_value_element("tags")).to have_selector 'tags.tagify'
        expect(tag_input).not_to have_selector 'tag'
      end

      it "shows filled state" do
        post.tag_list = ['some', 'tags', 'here', 'and', 'there']
        post.save

        visit path

        # expect(find_field_value_element("tags")).not_to have_text empty_dash
        # expect(find_field_value_element("tags")).not_to have_text 'some tags here and there'
        expect(tag_input).to have_selector 'tag', count: 5
      end
    end
  end
end

def tags_element(parent)
  parent.find 'tags.tagify'
end
