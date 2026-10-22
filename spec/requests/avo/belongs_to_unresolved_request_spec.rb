require "rails_helper"

# A belongs_to value that matches no record it may attach is a mistake in the form, so the form comes
# back with the error on that field instead of a 404 page.
RSpec.describe "Belongs to value that matches no record", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before { login_as admin_user }

  it "re-renders the new form with the error on the field and creates nothing" do
    expect {
      post "/admin/resources/comments", params: {comment: {body: "Hello", user_id: "no-such-user"}}
    }.not_to change(Comment, :count)

    expect(response).to have_http_status(422)
    expect(Capybara.string(response.body)).to have_css("[data-field-id='user'] .field-wrapper__error", text: "User is invalid")
  end

  it "re-renders the edit form with the error on the field and saves nothing" do
    post_record = create :post, user: admin_user, name: "Before"

    patch "/admin/resources/posts/#{post_record.to_param}", params: {post: {name: "After", user_id: "no-such-user"}}

    expect(response).to have_http_status(422)
    expect(Capybara.string(response.body)).to have_css("[data-field-id='user'] .field-wrapper__error", text: "User is invalid")
    expect(post_record.reload).to have_attributes(name: "Before", user: admin_user)
  end
end
