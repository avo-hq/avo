require "rails_helper"

RSpec.describe "Writing form params", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before { login_as admin_user }

  after { Avo::Resources::Comment.restore_items_from_backup }

  it "writes a param through the field the form shows, when the field is declared once per view" do
    Avo::Resources::Comment.with_temporary_items do
      field :body, as: :textarea, only_on: :forms, update_using: -> { value.upcase }
      field :body, as: :textarea, only_on: :show
    end
    comment = create :comment

    put "/admin/resources/comments/#{comment.to_param}", params: {comment: {body: "shouting"}}

    expect(comment.reload.body).to eq "SHOUTING"
  end

  it "keeps a polymorphic belongs_to's type when only its id is sent" do
    comment = create :comment, commentable: create(:project)
    other_project = create :project

    put "/admin/resources/comments/#{comment.to_param}", params: {comment: {commentable_id: other_project.to_param}}

    expect(comment.reload.commentable).to eq other_project
  end
end
