require "rails_helper"

# A belongs_to value that matches no record it may attach is a mistake in the form, so the form comes
# back with the error on that field instead of a 404 page.
RSpec.describe "Belongs to value that matches no record", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before { login_as admin_user }

  it "re-renders the new form with the error on every unresolved field and creates nothing" do
    expect {
      post "/admin/resources/comments", params: {comment: {body: "Hello", user_id: "no-such-user", commentable_type: "Post", commentable_id: "no-such-post"}}
    }.not_to change(Comment, :count)

    expect(response).to have_http_status(422)
    page = Capybara.string(response.body)
    expect(page).to have_css("[data-field-id='user'] .field-wrapper__error", text: "User is invalid")
    expect(page).to have_css("[data-field-id='commentable'] .field-wrapper__error", text: "Commentable is invalid")
  end

  it "re-renders the edit form with the error on the field, keeps the other edits and saves nothing" do
    post_record = create :post, user: admin_user, name: "Before", status: :draft

    # status is declared after user, so it is filled after the failing field
    patch "/admin/resources/posts/#{post_record.to_param}", params: {post: {name: "After", user_id: "no-such-user", status: "published"}}

    expect(response).to have_http_status(422)
    page = Capybara.string(response.body)
    expect(page).to have_css("[data-field-id='user'] .field-wrapper__error", text: "User is invalid")
    expect(page).to have_field("post[status]", with: "published")
    expect(post_record.reload).to have_attributes(name: "Before", user: admin_user, status: "draft")
  end

  it "saves no file uploaded with it" do
    project = create :project, user: admin_user

    # files is declared after user, and nothing else in the request changes the record
    patch "/admin/resources/projects/#{project.to_param}", params: {project: {
      user_id: "no-such-user",
      files: [Rack::Test::UploadedFile.new(Rails.root.join("db/seed_files/dummy-image.jpg"), "image/jpeg")]
    }}

    expect(response).to have_http_status(422)
    expect(project.reload.files).to be_empty
  end
end
