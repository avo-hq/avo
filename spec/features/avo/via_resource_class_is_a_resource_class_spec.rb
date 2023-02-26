require "rails_helper"

# The ethos of this spec and fix is that initially, we were sending model classes instead of resource classes in the GET params.
# The receivers then had to guess the resource from the model class, but that failed in some edge cases when multiple resources weere mapped to the same model.
RSpec.feature "ViaResourceClassIsAResourceClasses", type: :feature do
  let!(:post) { create :post }
  let!(:comment) { create :comment, commentable: post }

  it "displays the right resource class in association link" do
    visit "/admin/resources/z_posts/#{post.id}/comments?turbo_frame=has_many_field_show_photo_comments"

    within "tr[data-resource-id=\"#{comment.id}\"] [data-field-id=\"id\"]" do
      expect(page).to have_link comment.id, href: "/admin/resources/photo_comments/#{comment.id}?via_resource_class=ZPostResource&via_resource_id=#{post.slug}"
    end
  end

  it "displays the right breadcrumb link" do
    visit "/admin/resources/photo_comments/#{comment.id}?via_resource_class=ZPostResource&via_resource_id=#{post.id}"

    within ".breadcrumbs" do
      expect(page).to have_link post.name, href: "/admin/resources/z_posts/#{post.slug}"
    end
  end

  it "displays the right breadcrumb link" do
    visit "/admin/resources/photo_comments/#{comment.id}?via_resource_class=PostResource&via_resource_id=#{post.slug}"

    within ".breadcrumbs" do
      expect(page).to have_link post.name, href: "/admin/resources/posts/#{post.slug}"
    end
  end
end
