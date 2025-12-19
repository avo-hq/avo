require "rails_helper"

RSpec.describe "BooleanField", type: :system do
  describe "with regular input" do
    let!(:post) { create :post, name: "My Post", is_featured: nil }

    context "show" do
      it "displays the post values" do
        visit "/admin/resources/posts/#{post.to_param}"

        expect(page).to have_text "IS FEATURED"

        expect(find_field_value_element("is_featured")).to have_text empty_dash
      end
    end

    context "with nil_as_indeterminate enabled" do
      before(:all) do
        Avo::Resources::Post.with_temporary_items do
          field :is_featured, as: :boolean, nil_as_indeterminate: true
        end
      end

      after(:all) do
        Avo::Resources::Post.restore_items_from_backup
      end

      it "shows indeterminate icon on show view" do
        visit "/admin/resources/posts/#{post.to_param}"

        field_value = find_field_value_element("is_featured")

        expect(field_value).not_to have_text empty_dash
        expect(field_value).to have_css("svg[data-checked-state='indeterminate'].text-gray-400")
      end

      it "shows indeterminate icon on index view" do
        visit "/admin/resources/posts?view_type=table"

        field_value = index_field_wrapper(id: "is_featured", record_id: post.to_param)

        expect(field_value).not_to have_text empty_dash
        expect(field_value).to have_css("svg[data-checked-state='indeterminate'].text-gray-400")
      end
    end
  end
end
